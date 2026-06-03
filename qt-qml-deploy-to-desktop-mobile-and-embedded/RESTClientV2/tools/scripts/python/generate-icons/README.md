# App Icon Generator — Usage Guide

Generate every platform's app icons from a **single SVG** file. Run the same
script on **Windows, macOS, or Linux** and get one output folder with a
subfolder of icons per platform. The script auto-detects the OS and picks the
right SVG renderer for it. The script source is **heavily commented**, so you
can read `generate-icons.py` top-to-bottom to see what each line does.

```
python generate-icons.py --input-svg-file ./logo.svg --output-dir ./out
```

---

## 1. What you need

| Thing | Why | Notes |
|-------|-----|-------|
| **Python 3.9+** | Runs the script | 3.11 or newer recommended |
| **pip** (upgraded) | Installs the renderer package | Ships with Python |
| **One renderer package** | Turns the SVG into PNGs | `cairosvg` on macOS/Linux, `pyvips` on Windows — see below |

The script itself uses only the Python **standard library** for everything
except rasterising the SVG. The `.ico` / `.icns` containers, the `favicon.ico`,
the folder layout, and the Android "safe-zone" handling need **no extra
packages** — only the renderer does.

### The renderer dependency, explained

You install **one** of these, depending on your OS:

- **`cairosvg`** *(macOS / Linux default)* — converts the SVG into a PNG at any
  size. It relies on the system **cairo** graphics library, which macOS and
  Linux either already have or install easily. On Windows, cairo is often
  missing, which is why Windows uses the other option instead.

- **`pyvips[binary]`** *(Windows default)* — also converts the SVG into a PNG,
  using the **libvips** image library. The `[binary]` part is important: it
  pulls a wheel that **bundles libvips and its native libraries inside the pip
  package**, so there is **no separate DLL to install** on Windows. It also
  preserves transparency correctly.

You don't choose between them in the script — it tries the OS-appropriate one
first and automatically falls back to the other. It prints which it used
(`rasteriser: pyvips`).

> **Why not one package everywhere?** `cairosvg` needs a system cairo library
> that's painful to get on Windows, and the common pure-pip alternative
> (`svglib`) flattens transparency onto a white background, which ruins icons.
> `pyvips[binary]` avoids both problems on Windows.

---

## 2. Install (or upgrade) Python and pip

First check what you already have:

```powershell
python --version            # Windows
```
```bash
python3 --version           # macOS / Linux
```

You want **3.9 or newer**. If it's missing or too old, install it as below.

### Windows — via winget (recommended)

`winget` is the built-in Windows package manager (included with Windows 10/11
via "App Installer"). First find the latest available Python 3 package:

```powershell
winget search --id Python.Python --source winget
```

Look for the highest `Python.Python.3.X` entry in the output, then install it
(replace `3.X` with the version you saw, e.g. `3.14`):

```powershell
winget install -e --id Python.Python.3.X
```

To upgrade an existing winget-installed Python later:

```powershell
winget upgrade -e --id Python.Python.3.X
```

After installing, **close and reopen** your terminal so the new `python` is on
your PATH, then verify:

```powershell
python --version
python -m pip --version
```

> If `winget` isn't recognised, install "App Installer" from the Microsoft
> Store, or download the latest Python directly from
> <https://www.python.org/downloads/> and tick **"Add python.exe to PATH"**
> in the installer.

### macOS — via Homebrew

[Homebrew](https://brew.sh) is the common macOS package manager. Install it
once (skip if you already have `brew`):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install Python (this also gives you `pip`):

```bash
brew install python
```

Upgrade later with `brew upgrade python`. Verify:

```bash
python3 --version
python3 -m pip --version
```

> Alternatively, download the official installer from
> <https://www.python.org/downloads/macos/>.

### Linux — via your distro's package manager

**Debian / Ubuntu:**

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip
```

**Fedora:**

```bash
sudo dnf install -y python3 python3-pip
```

**Arch:**

```bash
sudo pacman -S --needed python python-pip
```

`python3-venv` (Debian/Ubuntu) is needed for the virtual environment in the
next step. Verify with `python3 --version` and `python3 -m pip --version`.

---

## 3. (Recommended) Create a virtual environment

A *virtual environment* ("venv") is a private folder holding an isolated copy
of Python and its packages, so the renderer package is installed **only for
this project** and never touches your system Python. To remove it, delete the
folder.

From the folder that contains `generate-icons.py`:

**Create it** (all platforms):

```bash
python -m venv .venv          # Windows
python3 -m venv .venv         # macOS / Linux
```

**Activate it:**

```powershell
.venv\Scripts\Activate.ps1     # Windows PowerShell
```
```bat
.venv\Scripts\activate.bat     # Windows Command Prompt
```
```bash
source .venv/bin/activate      # macOS / Linux
```

When active, your prompt starts with `(.venv)`. Run `deactivate` to leave.

### Windows PowerShell: if activation is blocked

If you see *"running scripts is disabled on this system"*, you have two ways
that **do not** change any permanent system setting:

**Option A — allow scripts for this terminal session only.** This resets the
moment you close the window:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
.venv\Scripts\Activate.ps1
```

**Option B — skip activation entirely and call the venv's Python directly.**
This needs no policy change at all — just point at the Python inside `.venv`:

```powershell
.venv\Scripts\python.exe -m pip install "pyvips[binary]"
.venv\Scripts\python.exe generate-icons.py --input-svg-file "./logo.svg" --output-dir "./out"
```

> Command Prompt (`cmd`) and macOS/Linux are unaffected by this — only
> PowerShell has an execution policy. There `.venv\Scripts\activate.bat` /
> `source .venv/bin/activate` just work.

---

## 4. Upgrade pip, then install the renderer

Upgrade pip and its build helpers first (avoids most install errors), then
install the one renderer package for your OS. Using `python -m pip` lets pip
update itself cleanly on Windows.

**Windows:**

```powershell
python -m pip install --upgrade pip setuptools wheel
python -m pip install "pyvips[binary]"
```

**macOS / Linux:**

```bash
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install cairosvg
```

`setuptools` and `wheel` are packaging helpers that let pip install prebuilt
packages cleanly; you don't use them directly.

**Verify the renderer loaded** (catches missing-native-library problems early):

```powershell
python -c "import pyvips; print('ok')"        # Windows
```
```bash
python3 -c "import cairosvg; print('ok')"      # macOS / Linux
```

If it prints `ok`, you're ready.

---

## 5. Run the script

It takes exactly **two arguments**: the input SVG and the output directory.
The icon name is taken automatically from the SVG file name.

**Windows:**

```powershell
python generate-icons.py --input-svg-file "./logo.svg" --output-dir "./out"
```

**macOS / Linux:**

```bash
python3 generate-icons.py --input-svg-file "./logo.svg" --output-dir "./out"
```

**Paths:** forward slashes (`/`) work on every OS, including Windows. Wrap a
path in **double quotes** if it contains spaces (e.g. `"./my logo.svg"`). `~`
expands to your home folder.

---

## 6. What you get

```
out/
├── windows/   icon-16/24/32/48/64/96/128/256.png  +  <name>.ico  +  <name>.rc
├── linux/     <size>x<size>/apps/<name>.png (16/22/24/32/48/64/96/128/256/512) + scalable/apps/<name>.svg
├── macos/     <name>.iconset/*.png (10 files, 16–1024 px)      + <name>.icns (10 OSType chunks)
├── android/   res/mipmap-*/ic_launcher.png + ic_launcher_foreground.png
│              play_store_512.png
├── ios/       AppIcon-40/58/60/80/87/120/152/167/180/1024.png
└── web/       favicon.ico
               favicon-16x16.png  favicon-32x32.png  favicon-96x96.png
               apple-touch-icon.png  (180 px – iOS/iPadOS home screen)
               icon-192.png  icon-384.png  icon-512.png  (PWA manifest)
               maskable-icon-192.png  maskable-icon-512.png  (PWA maskable)
```

- **windows** — PNGs at 8 sizes (16–256 px) covering classic, HiDPI 125 %–200 %
  display scaling, plus a packed multi-size `.ico` and a `.rc` Windows Resource
  Script that embeds the icon into the `.exe` when added as a CMake source.
- **linux** — hicolor-theme PNGs at 10 sizes (16–512 px, including the 22/24 px
  sizes used by panels and system trays), plus the source SVG in `scalable` for
  true vector rendering on any HiDPI display.
- **macos** — a complete `.iconset` folder (10 PNGs, 16–1024 px) plus a
  `.icns` bundle with all 10 OSType chunks — identical output to
  `iconutil -c icns`. Each of the 5 logical display sizes (16/32/128/256/512 pt)
  has both a @1x and a @2x Retina chunk, so macOS always picks the
  sharpest pre-rendered image on every display.
- **android** — icons are placed under `res/mipmap-{density}/` so the directory
  can be used directly as `QT_ANDROID_PACKAGE_SOURCE_DIR`. Includes legacy square
  launcher icons for all five density buckets (mdpi–xxxhdpi), adaptive-icon
  foreground layers (artwork kept inside the 66 dp safe zone to survive
  circle/squircle cropping), and the 512 px Play Store listing icon.
- **ios** — the full Apple HIG 2026 set: 1024 px App Store master plus all
  on-device sizes for Home Screen, Spotlight, Settings, and Notifications
  across iPhone and iPad models. Xcode 16 + can auto-generate from the master,
  but pre-rendered PNGs give pixel-perfect results on every device.
- **web** — `favicon.ico` (16/32/48 px), standalone favicon PNGs (16/32/96 px),
  Apple touch icon (180 px), PWA manifest icons (192/384/512 px), and maskable
  PWA icons (192/512 px — artwork centred in the 80 % safe zone so browsers can
  crop to circle/squircle without clipping the logo).

---

## 7. Everyday use after setup

Setup (steps 2–4) is one-time. After that you only:

```bash
# activate the venv (step 3), then:
python generate-icons.py --input-svg-file "./logo.svg" --output-dir "./out"
# deactivate when done
```

---

## 8. Troubleshooting

- **`OSError: no library called "cairo" was found`** (Windows) — this is the
  reason Windows uses `pyvips`. Install `pyvips[binary]` (step 4) instead of
  `cairosvg`; the script picks it up automatically.
- **`ModuleNotFoundError`** for the renderer — the package isn't installed in
  the Python you're using. Make sure the venv is active (`(.venv)` in your
  prompt), then re-run the install command.
- **`error: externally-managed-environment`** (Linux) — your system Python is
  protected. Use a virtual environment (step 3); that's the intended fix.
- **`python` not found** — on macOS/Linux use `python3`. On Windows, reopen the
  terminal after install, or reinstall with PATH enabled.
- **An exotic SVG looks slightly off on Windows** — `pyvips` renders SVG via
  librsvg, which handles typical logos faithfully but supports fewer advanced
  SVG filter effects than cairo. Simplify the effect in the source SVG.

---

## 9. Strict type checking — does `pyright generate-icons.py` run strict?

**No — by itself it runs pyright's *standard* mode, not strict, and there is no
`--strict` command-line flag.** Strict mode is turned on by a **config file**.
A `pyrightconfig.json` is included next to the script:

```json
{
  "typeCheckingMode": "strict"
}
```

With that file present, just run pyright from that folder and it checks in
strict mode:

```bash
python -m pip install pyright
pyright generate-icons.py
```

You should see `0 errors, 0 warnings`. (`pyright` is the type checker behind
VS Code's Pylance; you only need it to verify or edit the code, not to run it.)

**In VS Code (Pylance):** strict mode is a setting rather than the config flag.
Open Settings and set **Python › Analysis: Type Checking Mode** to `strict`
(or add `"python.analysis.typeCheckingMode": "strict"` to your settings JSON).
The included `pyrightconfig.json` is also respected by Pylance, so opening this
folder in VS Code enables strict automatically.
