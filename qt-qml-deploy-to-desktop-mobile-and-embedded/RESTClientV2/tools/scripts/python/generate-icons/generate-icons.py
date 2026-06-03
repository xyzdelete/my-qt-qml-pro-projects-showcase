#!/usr/bin/env python3
"""Generate every platform's app icons from one SVG file, on any OS.

WHAT THIS SCRIPT DOES
---------------------
You give it one SVG and an output folder. It rasterises (renders) that SVG to
PNGs at the sizes each platform needs in 2026, and also writes the platform
icon "container" files (.ico for Windows, .icns for macOS) plus a web favicon.
Run it on Windows, macOS, or Linux and you get the same output tree.

THE ONLY MOVING PART THAT NEEDS A LIBRARY IS SVG -> PNG
-------------------------------------------------------
Everything else (folder layout, .ico/.icns byte formats, the Android safe-zone
math) is done with Python's standard library, so it needs no extra packages.
Only the SVG renderer is a third-party dependency, and there are two options:
  * cairosvg  -> default on macOS/Linux   (pip install cairosvg)
  * pyvips    -> default on Windows        (pip install "pyvips[binary]")
pyvips' "[binary]" wheel bundles its own native library, so Windows users do
NOT need to install a separate cairo DLL.

OUTPUT LAYOUT
-------------
    <output-dir>/
      windows/  16/24/32/48/64/96/128/256 px PNGs + <name>.ico + <name>.rc
      linux/    hicolor 16/22/24/32/48/64/96/128/256/512 px PNGs + scalable SVG
      macos/    16-1024 px .iconset PNGs + <name>.icns
      android/  launcher mipmaps 48-192 px, adaptive foregrounds, play_store_512
      ios/      40/58/60/80/87/120/152/167/180/1024 px PNGs (full set)
      web/      favicon.ico + favicon/apple-touch/PWA PNGs + maskable PWA icons

USAGE
-----
    pip install cairosvg              # macOS/Linux
    pip install "pyvips[binary]"      # Windows
    python generate-icons.py --input-svg-file ./logo.svg --output-dir ./out
"""

# ``from __future__ import annotations`` makes every type annotation in this
# file be treated as a plain string at runtime instead of being evaluated.
# That lets us write modern annotations (e.g. ``str | None``, ``tuple[int]``)
# even on older Python versions, and lets a class refer to itself in its own
# methods (used by the _VipsImage Protocol below).
from __future__ import annotations

# --- Standard-library imports (no installation needed) ----------------------
import argparse  # parses the --input-svg-file / --output-dir command-line flags
import importlib  # imports the renderer ("cairosvg"/"pyvips") by name at runtime
import platform  # tells us which OS we are running on (to pick the renderer)
import shutil  # used to copy the source SVG into the Linux "scalable" folder
import struct  # packs raw bytes for the .ico and .icns binary file formats
import sys  # used to print errors to stderr and to set the process exit code
import tempfile  # creates throwaway folders for intermediate PNGs
import xml.etree.ElementTree as ET  # reads/writes SVG (which is XML) for Android
from dataclasses import dataclass  # concise, typed "record" classes
from pathlib import Path  # OS-independent file paths (handles / vs \ for us)
from typing import Callable, Final, Protocol, cast  # typing helpers (see below)

# SVG is an XML format living in this namespace; we need it to build XML tags.
SVG_NS: Final[str] = "http://www.w3.org/2000/svg"
# Some SVGs reference images/links via the "xlink" namespace.
XLINK_NS: Final[str] = "http://www.w3.org/1999/xlink"
# Tell ElementTree to emit clean ``xmlns=...`` (no "ns0:" prefixes) when we
# serialise the SVG we build for Android. ("" = the default namespace.)
ET.register_namespace("", SVG_NS)
ET.register_namespace("xlink", XLINK_NS)

# A short name for "a function that takes (source SVG, pixel size, destination)
# and writes a PNG, returning nothing". Both renderer backends match this shape,
# so the rest of the code only depends on this type, not on which library runs.
RasterizeFn = Callable[[Path, int, Path], None]


# --- Rasteriser backends (loaded dynamically for clean typing) --------------
#
# We import the renderer via importlib (by string name) instead of a normal
# ``import cairosvg`` at the top. Two reasons:
#   1. The file must type-check cleanly even if neither library is installed;
#      a dynamic import has nothing for the type checker to flag as "missing".
#   2. We only want to require whichever library this OS actually uses.
#
# Because the libraries ship no type information, we describe just the small
# slice we use with a "Protocol" (a structural interface) and ``cast`` the
# dynamically-loaded object to it. That keeps strict type checking happy.


class _Svg2Png(Protocol):
    # Describes cairosvg's ``svg2png`` function: keyword-only args, returns None.
    def __call__(
        self, *, url: str, output_width: int, output_height: int, write_to: str
    ) -> None: ...


class _VipsImage(Protocol):
    # Describes the parts of a pyvips image object we touch.
    bands: int  # number of colour channels (4 means it already has alpha)
    def addalpha(self) -> _VipsImage: ...  # returns a copy with an alpha channel
    def write_to_file(self, path: str) -> None: ...  # saves the image to disk


class _VipsImageFactory(Protocol):
    # Describes pyvips' ``Image`` class, specifically its ``thumbnail`` builder.
    def thumbnail(
        self, filename: str, width: int, *, height: int, size: str
    ) -> _VipsImage: ...


def _load_cairosvg() -> RasterizeFn:
    # Import cairosvg by name; raises ImportError if it isn't installed, or
    # OSError if its native cairo library can't be found (common on Windows).
    module = importlib.import_module("cairosvg")
    # Grab the svg2png function and tell the type checker its real signature.
    svg2png: _Svg2Png = cast("_Svg2Png", getattr(module, "svg2png"))

    # The actual render function we hand back. cairosvg renders the SVG to a
    # square PNG of the requested size and writes it straight to ``dest``.
    def render(src: Path, size: int, dest: Path) -> None:
        svg2png(
            url=str(src), output_width=size, output_height=size, write_to=str(dest)
        )

    return render


def _load_pyvips() -> RasterizeFn:
    # Import pyvips by name (same ImportError/OSError behaviour as above).
    module = importlib.import_module("pyvips")
    # Grab the Image class and describe it to the type checker.
    image: _VipsImageFactory = cast("_VipsImageFactory", getattr(module, "Image"))

    def render(src: Path, size: int, dest: Path) -> None:
        # ``thumbnail`` loads the SVG and scales it; size="force" makes the
        # output exactly size x size (matching cairosvg's behaviour).
        result = image.thumbnail(str(src), size, height=size, size="force")
        # If the rendered image has fewer than 4 channels it has no alpha, so
        # add one; this keeps transparent areas transparent.
        if result.bands < 4:
            result = result.addalpha()
        # Write the PNG to disk (the .png extension tells pyvips the format).
        result.write_to_file(str(dest))

    return render


def load_rasterizer() -> tuple[str, RasterizeFn]:
    """Pick an SVG rasteriser for this OS (pyvips on Windows, cairosvg else).

    Returns a ``(name, function)`` pair so the caller can print which backend
    was chosen. Tries the OS-preferred backend first, then the other one.
    """
    # Map each backend name to the loader that produces its render function.
    backends: dict[str, Callable[[], RasterizeFn]] = {
        "cairosvg": _load_cairosvg,
        "pyvips": _load_pyvips,
    }
    # On Windows prefer pyvips (no cairo DLL needed); elsewhere prefer cairosvg.
    order: tuple[str, ...] = (
        ("pyvips", "cairosvg")
        if platform.system() == "Windows"
        else ("cairosvg", "pyvips")
    )
    # Collect failures so the final error message can show what we attempted.
    tried: list[str] = []
    for name in order:
        try:
            # Call the loader; if the library is present this succeeds and we
            # return immediately. ImportError = not installed; OSError = native
            # library missing (e.g. cairo on Windows) -> fall through to next.
            return name, backends[name]()
        except (ImportError, OSError) as exc:
            tried.append(f"{name} ({type(exc).__name__})")
    # Neither backend worked: tell the user exactly what to install.
    raise RuntimeError(
        "No SVG rasteriser available. Install one:\n"
        '  Windows:     python -m pip install "pyvips[binary]"\n'
        "  macOS/Linux: python3 -m pip install cairosvg\n"
        f"  tried: {', '.join(tried)}"
    )


# --- ICO / ICNS container writers (standard library) ------------------------
#
# .ico (Windows) and .icns (macOS) are just containers that bundle several PNG
# images at different sizes into one file. Their byte layouts are public, so we
# build them by hand with ``struct`` (which packs Python numbers into raw
# bytes) instead of needing an imaging library.


def write_ico(entries: list[tuple[int, bytes]], dest: Path) -> None:
    """Pack ``(size, png_bytes)`` pairs into a multi-resolution ``.ico`` file."""
    # Sort by size so the directory entries are in ascending order.
    ordered = sorted(entries)
    count: int = len(ordered)  # how many images go in the file
    directory: bytes = b""  # the table of contents (one 16-byte entry per image)
    images: bytes = b""  # the concatenated PNG image data
    # Image data starts right after the 6-byte header and the directory table.
    offset: int = 6 + count * 16
    for size, data in ordered:
        # In .ico, a size of 256 is stored as 0 in the single width/height byte.
        dim: int = 0 if size >= 256 else size
        # One directory entry: width, height, palette count(0), reserved(0),
        # colour planes(1), bits-per-pixel(32 for RGBA), byte length, and the
        # offset where this image's bytes begin. "<" = little-endian.
        directory += struct.pack("<BBBBHHII", dim, dim, 0, 0, 1, 32, len(data), offset)
        images += data  # append the actual PNG bytes
        offset += len(data)  # next image starts after this one
    # File = 6-byte header (reserved=0, type=1 meaning icon, image count) +
    # the directory table + all the image bytes.
    dest.write_bytes(struct.pack("<HHH", 0, 1, count) + directory + images)


# .icns bundles images as typed chunks. Each chunk has a 4-byte "OSType" code
# that tells macOS both the pixel dimensions and whether this is a @1x or @2x
# Retina image. The complete table below mirrors exactly what Apple's
# ``iconutil -c icns`` produces from a standard 10-file .iconset folder.
#
# Why 10 chunks, not 7?
# The old approach used 7 codes (icp4-icp6, ic07-ic10), keyed by pixel size.
# That is wrong because:
#   • Two different codes can carry the same pixel size (e.g. both ic08 and ic13
#     are 256×256 PNGs, but ic08 = 256 pt @1x and ic13 = 128 pt @2x Retina).
#   • The old icp6 entry (64 px "64 pt @1x") has no matching iconset file; the
#     64 px file ``icon_32x32@2x.png`` is semantically 32 pt @2x and must use
#     ic12 instead.
# Keying by *filename* (not pixel size) removes all ambiguity: each iconset file
# has exactly one OSType and each OSType appears exactly once in the table.
#
# Layout: (4-byte OSType code, iconset filename)
_ICNS_ENTRIES: Final[tuple[tuple[bytes, str], ...]] = (
    (b"icp4", "icon_16x16.png"),         # 16×16   — 16 pt @1x
    (b"ic11", "icon_16x16@2x.png"),      # 32×32   — 16 pt @2x Retina
    (b"icp5", "icon_32x32.png"),         # 32×32   — 32 pt @1x
    (b"ic12", "icon_32x32@2x.png"),      # 64×64   — 32 pt @2x Retina
    (b"ic07", "icon_128x128.png"),       # 128×128 — 128 pt @1x
    (b"ic13", "icon_128x128@2x.png"),    # 256×256 — 128 pt @2x Retina
    (b"ic08", "icon_256x256.png"),       # 256×256 — 256 pt @1x
    (b"ic14", "icon_256x256@2x.png"),    # 512×512 — 256 pt @2x Retina
    (b"ic09", "icon_512x512.png"),       # 512×512 — 512 pt @1x
    (b"ic10", "icon_512x512@2x.png"),    # 1024×1024 — 512 pt @2x Retina
)


def write_icns(files: dict[str, bytes], dest: Path) -> None:
    """Assemble PNG payloads keyed by iconset filename into a valid ``.icns`` file."""
    body: bytes = b""
    # For each entry, emit a chunk: 4-byte OSType + 4-byte big-endian length
    # (the length field includes the 8-byte header itself) + raw PNG bytes.
    # ``.get`` skips any entry whose file wasn't provided (graceful subset).
    for ostype, filename in _ICNS_ENTRIES:
        data = files.get(filename)
        if data is not None:
            body += ostype + struct.pack(">I", len(data) + 8) + data
    # The complete file = magic word "icns" + 4-byte total length + all chunks.
    dest.write_bytes(b"icns" + struct.pack(">I", len(body) + 8) + body)


# --- Android adaptive-icon safe-zone wrapper (standard library) -------------
#
# Android "adaptive" icons crop the foreground to various shapes (circle,
# squircle, ...), so artwork must stay within an inner "safe zone" (66 of the
# 108 dp canvas) or it gets clipped. Rather than composite images, we build a
# new SVG that places the original artwork, scaled down, centred in that zone.


def _length(value: str | None) -> float | None:
    # Parse the leading number out of an SVG length like "512", "512px", "64pt".
    if value is None:
        return None
    digits: str = ""
    for char in value.strip():
        # Keep digits and the few characters that can appear in a number...
        if char.isdigit() or char in ".-":
            digits += char
        else:
            break  # ...and stop at the first unit letter (e.g. the "p" in "px").
    try:
        return float(digits)
    except ValueError:
        return None  # couldn't parse a number


def build_safe_zone_svg(src: Path, dest: Path, safe_dp: int, canvas_dp: int) -> bool:
    """Wrap ``src`` centred inside the adaptive-icon safe zone; return success.

    Returns True if it produced a wrapper SVG at ``dest``; False if the source
    couldn't be parsed (the caller then falls back to full-bleed rendering).
    """
    try:
        # Parse the SVG file and grab its root <svg> element.
        root: ET.Element = ET.parse(str(src)).getroot()
    except ET.ParseError:
        return False  # malformed SVG -> signal failure so caller can fall back
    # The viewBox defines the artwork's coordinate system. If it's missing, try
    # to derive one from width/height, else assume a 100x100 box.
    viewbox: str | None = root.get("viewBox")
    if viewbox is None:
        width = _length(root.get("width"))
        height = _length(root.get("height"))
        viewbox = f"0 0 {width:g} {height:g}" if width and height else "0 0 100 100"
    # The inset on each side that centres the safe zone within the full canvas.
    offset: float = (canvas_dp - safe_dp) / 2
    # Turn the original <svg> into a nested, repositioned, resized sub-image:
    root.set("viewBox", viewbox)  # ensure it has an explicit coordinate system
    root.set("x", f"{offset:g}")  # shift right by the inset
    root.set("y", f"{offset:g}")  # shift down by the inset
    root.set("width", str(safe_dp))  # shrink to the safe-zone width
    root.set("height", str(safe_dp))  # shrink to the safe-zone height
    root.set("preserveAspectRatio", "xMidYMid meet")  # centre + keep proportions
    # Build a new outer <svg> the size of the full adaptive canvas...
    outer: ET.Element = ET.Element(
        f"{{{SVG_NS}}}svg",  # "{namespace}tag" is ElementTree's namespaced-name form
        {
            "width": str(canvas_dp),
            "height": str(canvas_dp),
            "viewBox": f"0 0 {canvas_dp} {canvas_dp}",
        },
    )
    outer.append(root)  # ...and nest the repositioned original inside it.
    # Serialise the new SVG tree to text and write it to the temp wrapper file.
    dest.write_text(ET.tostring(outer, encoding="unicode"), encoding="utf-8")
    return True


# --- 2026 platform icon size tables -----------------------------------------
#
# These constants define the complete per-platform icon sizes for 2026. Each
# constant is annotated with ``Final`` to tell the type checker it must not
# be reassigned anywhere in this file.


@dataclass(frozen=True)
class Density:
    # One Android screen-density bucket. ``frozen=True`` makes it immutable.
    name: str  # mipmap folder suffix, e.g. "xxxhdpi"
    launcher: int  # legacy square launcher icon size in px
    canvas: int  # adaptive-icon canvas size in px for this density


# Windows .ico full set: 16/24/32/48 are the classic required sizes; 64/96/128
# cover HiDPI (125 %–200 % scaling) on Windows 10/11 where the OS picks the
# nearest pre-rendered size rather than upscaling (Microsoft icon guidelines).
WINDOWS_SIZES: Final[tuple[int, ...]] = (16, 24, 32, 48, 64, 96, 128, 256)
# Linux hicolor-theme PNG sizes (Freedesktop icon-theme specification).
# 48 is the only mandatory size; 22/24 are used by panels/system trays; 96/512
# cover HiDPI and app-grid zoom levels in GNOME/KDE.
LINUX_SIZES: Final[tuple[int, ...]] = (16, 22, 24, 32, 48, 64, 96, 128, 256, 512)
# iOS full icon set (Apple HIG 2026).
# Xcode 16 + can auto-generate all sizes from the 1024 master, but providing
# pre-rendered PNGs ensures pixel-perfect rendering on every device/context:
#   40  – Spotlight @2x / Notifications @2x (older devices)
#   58  – Settings @3x (iPhone)
#   60  – Notifications @3x (iPhone)
#   80  – Spotlight @2x (iPad)
#   87  – Settings @3x (iPad Pro)
#  120  – Home screen @2x iPhone / Spotlight @3x
#  152  – Home screen @2x iPad
#  167  – Home screen @2x iPad Pro
#  180  – Home screen @3x iPhone
# 1024  – App Store master (required; no transparency)
IOS_SIZES: Final[tuple[int, ...]] = (40, 58, 60, 80, 87, 120, 152, 167, 180, 1024)
# Android density buckets: (folder name, legacy launcher px, adaptive canvas px).
ANDROID_DENSITIES: Final[tuple[Density, ...]] = (
    Density("mdpi", 48, 108),
    Density("hdpi", 72, 162),
    Density("xhdpi", 96, 216),
    Density("xxhdpi", 144, 324),
    Density("xxxhdpi", 192, 432),
)
ANDROID_PLAY_STORE: Final[int] = 512  # Google Play store listing icon px
ANDROID_SAFE_ZONE_DP: Final[int] = 66  # inner safe area of the adaptive icon
ANDROID_CANVAS_DP: Final[int] = 108  # full adaptive-icon canvas
# Sizes packed into the web favicon.ico (legacy browser support).
FAVICON_SIZES: Final[tuple[int, ...]] = (16, 32, 48)
# Standalone web PNGs: (pixel size, output filename).
# 16/32/96   – favicon PNGs (96 covers HiDPI displays)
# 180        – apple-touch-icon: iOS/iPadOS "Add to Home Screen"
# 192        – PWA / Android Chrome manifest minimum required icon
# 384        – PWA intermediate size for smooth scaling on large screens
# 512        – PWA splash screen / largest manifest icon
WEB_PNGS: Final[tuple[tuple[int, str], ...]] = (
    (16, "favicon-16x16.png"),
    (32, "favicon-32x32.png"),
    (96, "favicon-96x96.png"),
    (180, "apple-touch-icon.png"),
    (192, "icon-192.png"),
    (384, "icon-384.png"),
    (512, "icon-512.png"),
)
# Maskable PWA icons: artwork wrapped so it fits the central 80 % safe zone.
# Browsers / Android may crop to a circle or squircle, so anything outside
# 80 % of the canvas risks being hidden (same principle as Android adaptive).
# Two sizes cover the Web App Manifest minimum (192) and the splash (512).
PWA_MASKABLE_CANVAS_DP: Final[int] = 100  # arbitrary canvas unit (defines ratio)
PWA_MASKABLE_SAFE_ZONE_DP: Final[int] = 80  # 80 % of canvas = safe area
WEB_MASKABLE_SIZES: Final[tuple[int, ...]] = (192, 512)

# macOS expects a folder of PNGs with these exact names ("@2x" = retina/double).
MACOS_ICONSET: Final[tuple[tuple[int, str], ...]] = (
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
)


# --- Build context and per-platform builders --------------------------------


@dataclass(frozen=True)
class Context:
    # A small bundle of values passed to every builder, so each builder has the
    # renderer, the source SVG, the output root, and the icon name on hand.
    rasterize: RasterizeFn  # the chosen SVG -> PNG function
    svg: Path  # the source SVG path
    out: Path  # the root output directory
    name: str  # base icon name (taken from the SVG file name)


def _png(ctx: Context, size: int, dest: Path) -> None:
    # Helper: make sure the destination folder exists, then render one PNG.
    dest.parent.mkdir(parents=True, exist_ok=True)
    ctx.rasterize(ctx.svg, size, dest)


def _ico_from_sizes(ctx: Context, sizes: tuple[int, ...], dest: Path) -> None:
    # Build a .ico by rendering each size to a temporary PNG, reading the bytes,
    # then packing them all into one .ico file.
    entries: list[tuple[int, bytes]] = []
    # TemporaryDirectory auto-deletes itself (and the temp PNGs) when the block
    # ends, so we don't leave clutter behind.
    with tempfile.TemporaryDirectory() as tmp:
        for size in sizes:
            tmp_png = Path(tmp) / f"{size}.png"
            ctx.rasterize(ctx.svg, size, tmp_png)
            entries.append((size, tmp_png.read_bytes()))
    dest.parent.mkdir(parents=True, exist_ok=True)
    write_ico(entries, dest)


def build_windows(ctx: Context) -> None:
    # Windows: a PNG per size, a packed .ico, and a .rc that embeds the icon.
    folder: Path = ctx.out / "windows"
    for size in WINDOWS_SIZES:
        _png(ctx, size, folder / f"icon-{size}.png")
    _ico_from_sizes(ctx, WINDOWS_SIZES, folder / f"{ctx.name}.ico")
    # The RC file tells the Windows linker to embed the .ico into the .exe.
    # IDI_ICON1 is the conventional first-icon resource ID; Windows picks the
    # icon with the lowest ID as the application icon shown in Explorer.
    rc: Path = folder / f"{ctx.name}.rc"
    rc.write_text(f'IDI_ICON1 ICON "{ctx.name}.ico"\n', encoding="utf-8")


def build_linux(ctx: Context) -> None:
    # Linux: hicolor-theme PNGs in "<size>x<size>/apps/<name>.png" folders...
    folder: Path = ctx.out / "linux"
    for size in LINUX_SIZES:
        _png(ctx, size, folder / f"{size}x{size}" / "apps" / f"{ctx.name}.png")
    # ...plus the original SVG in the "scalable" folder (Linux can use vectors).
    scalable: Path = folder / "scalable" / "apps" / f"{ctx.name}.svg"
    scalable.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(ctx.svg, scalable)


def build_macos(ctx: Context) -> None:
    # macOS: render the .iconset folder of PNGs (the names matter to Apple)...
    iconset: Path = ctx.out / "macos" / f"{ctx.name}.iconset"
    for size, filename in MACOS_ICONSET:
        _png(ctx, size, iconset / filename)
    # ...then read every iconset file back, keyed by filename, and pack into
    # a .icns. _ICNS_ENTRIES maps each filename to its correct OSType chunk.
    files: dict[str, bytes] = {
        fname: (iconset / fname).read_bytes()
        for _, fname in MACOS_ICONSET
    }
    write_icns(files, ctx.out / "macos" / f"{ctx.name}.icns")


def build_android(ctx: Context) -> None:
    # Android: one legacy square launcher icon + one adaptive-icon foreground
    # per screen-density bucket, plus the flat 512 px Play Store listing icon.
    folder: Path = ctx.out / "android"
    # Build the safe-zone wrapper SVG once in a temp folder, then reuse it for
    # every density's adaptive foreground.
    with tempfile.TemporaryDirectory() as tmp:
        wrapper: Path = Path(tmp) / "foreground.svg"
        padded: bool = build_safe_zone_svg(
            ctx.svg, wrapper, ANDROID_SAFE_ZONE_DP, ANDROID_CANVAS_DP
        )
        # Use the safe-zone wrapper if it built; otherwise fall back to the
        # raw SVG (full-bleed) so the foreground still gets produced.
        source: Path = wrapper if padded else ctx.svg
        for density in ANDROID_DENSITIES:
            mipmap: Path = folder / "res" / f"mipmap-{density.name}"
            # Legacy square launcher icon for this density.
            _png(ctx, density.launcher, mipmap / "ic_launcher.png")
            # Adaptive-icon foreground layer (rendered from the wrapper SVG).
            fg: Path = mipmap / "ic_launcher_foreground.png"
            fg.parent.mkdir(parents=True, exist_ok=True)
            ctx.rasterize(source, density.canvas, fg)
    # The Google Play store listing icon (rendered from the raw SVG).
    _png(ctx, ANDROID_PLAY_STORE, folder / "play_store_512.png")


def build_ios(ctx: Context) -> None:
    # iOS: the full Apple HIG 2026 set as pre-rendered PNGs. Xcode 16+ can
    # auto-generate all device sizes from the 1024 master alone, but explicit
    # files guarantee pixel-perfect results on every iPhone/iPad context
    # (Home Screen, Spotlight, Settings, Notifications) without relying on
    # Xcode's downscaling. The 1024 master itself is also required for the
    # App Store and must have no alpha/transparency channel.
    folder: Path = ctx.out / "ios"
    for size in IOS_SIZES:
        _png(ctx, size, folder / f"AppIcon-{size}.png")


def build_web(ctx: Context) -> None:
    # Web: the standalone favicon/apple-touch/PWA PNGs, plus a favicon.ico.
    folder: Path = ctx.out / "web"
    for size, filename in WEB_PNGS:
        _png(ctx, size, folder / filename)
    _ico_from_sizes(ctx, FAVICON_SIZES, folder / "favicon.ico")
    # Maskable PWA icons: wrap artwork in the 80 % safe zone so browsers can
    # crop to circle/squircle without cutting into the logo. Reuses the same
    # adaptive-icon wrapping logic as Android; falls back to full-bleed if the
    # SVG can't be parsed.
    with tempfile.TemporaryDirectory() as tmp:
        wrapper: Path = Path(tmp) / "maskable.svg"
        padded: bool = build_safe_zone_svg(
            ctx.svg, wrapper, PWA_MASKABLE_SAFE_ZONE_DP, PWA_MASKABLE_CANVAS_DP
        )
        source: Path = wrapper if padded else ctx.svg
        for size in WEB_MASKABLE_SIZES:
            dest: Path = folder / f"maskable-icon-{size}.png"
            dest.parent.mkdir(parents=True, exist_ok=True)
            ctx.rasterize(source, size, dest)


# A builder is any function that takes the Context and produces files.
Builder = Callable[[Context], None]

# The full set of builders run for every invocation (all platforms, always).
BUILDERS: Final[tuple[Builder, ...]] = (
    build_windows,
    build_linux,
    build_macos,
    build_android,
    build_ios,
    build_web,
)


# --- CLI --------------------------------------------------------------------


def parse_args() -> argparse.Namespace:
    # Define and parse the two required command-line flags.
    parser = argparse.ArgumentParser(
        description="Generate every platform's app icons from one SVG.",
    )
    parser.add_argument(
        "--input-svg-file", required=True, help="path to the source .svg file"
    )
    parser.add_argument(
        "--output-dir", required=True, help="directory to write all icons into"
    )
    return parser.parse_args()


def main() -> int:
    # Returns a process exit code: 0 = success, non-zero = a specific failure.
    args: argparse.Namespace = parse_args()
    # ``args`` attributes are untyped, so wrap in str() before building Paths.
    # ``.expanduser()`` turns a leading "~" into your home folder; ``.resolve()``
    # makes the path absolute and normalises slashes for the current OS.
    svg: Path = Path(str(args.input_svg_file)).expanduser().resolve()
    out: Path = Path(str(args.output_dir)).expanduser().resolve()

    # Fail early with a clear message if the input file isn't there.
    if not svg.is_file():
        print(f"error: SVG not found: {svg}", file=sys.stderr)
        return 1

    # Choose the SVG renderer for this OS (or report how to install one).
    try:
        engine, rasterize = load_rasterizer()
    except RuntimeError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    print(f"rasteriser: {engine}")  # tell the user which backend was used
    # Bundle everything the builders need; ``name`` comes from the SVG filename.
    ctx = Context(rasterize=rasterize, svg=svg, out=out, name=svg.stem)
    try:
        # Run every platform builder in turn.
        for builder in BUILDERS:
            builder(ctx)
            # "build_windows" -> "windows" for a tidy progress line.
            print(f"built {builder.__name__.removeprefix('build_')} icons")
    except (RuntimeError, OSError) as exc:
        # A rendering or file error mid-run: report it and exit non-zero.
        print(f"error: {exc}", file=sys.stderr)
        return 3

    print(f"done -> {out}")
    return 0


# Only run main() when executed directly (not when imported as a module).
# ``SystemExit`` with main()'s return value sets the shell exit code.
if __name__ == "__main__":
    raise SystemExit(main())
