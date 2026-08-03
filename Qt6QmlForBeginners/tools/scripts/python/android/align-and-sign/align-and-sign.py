#!/usr/bin/env python3
"""Zip-align and sign the release Android .apk / .aab produced by a Qt build.

WHAT THIS SCRIPT DOES
----------------------
After `cmake --build` (and the CMake `aab` target) produce an unsigned
release `.apk` and/or `.aab` under a build directory's `android-build/`
folder, this script:

  1. Finds a signing keystore (a `.jks`/`.keystore` file) under
     `<repo-root>/.android-keystore/`, asking which one to use if there is
     more than one.
  2. Opens it with `keytool` to confirm it actually contains a certificate,
     printing the certificate details. If it doesn't (or the password is
     wrong), it prints the error and exits without touching any build output.
  3. Zip-aligns the unsigned `.apk` (`zipalign`), then signs the aligned copy
     with `apksigner`, writing `<project>-release-aligned-signed.apk`.
  4. Signs the `.aab` in place with `jarsigner` (no alignment needed for
     bundles), writing `<project>-release-signed.aab`.

Both outputs are written to `<build-dir>/android-build/signed/` by default.
`<project>` is read straight out of the repo's `project(...)` call in
`CMakeLists.txt`, so the signed files are always easy to spot.

TWO MODES
---------
* **Interactive** (default): missing information (build dir, which keystore
  file, which key alias) is asked for on the terminal; passwords are asked
  for with a hidden prompt (nothing echoed to the terminal) whenever they
  aren't already available from an environment variable.
* **Silent** (`--silent`): never prompts. Every required value must be
  passed as a named argument or be resolvable from a single keystore/alias
  or an environment variable. Missing input is a hard error with a non-zero
  exit code -- this is the mode to use from a CMake custom target or CI.

Every argument is a `--named-flag`; there is no positional/order-dependent
argument, so it's safe to reorder or omit any of them.

SECRETS
-------
Android keystores technically support two independent passwords (one for
the keystore file itself, one per key alias inside it) -- but the near
universal convention (and what `keytool -genkeypair` does when you just
press Enter at the key-password prompt) is to reuse the keystore password
as the key password too. This script follows that convention: there is a
single password, read from one environment variable (`--password-env`,
default `ANDROID_KEYSTORE_PASSWORD`), used for both `-storepass`/`--ks-pass`
and `-keypass`/`--key-pass`. If your keystore genuinely uses two different
passwords, regenerate the key's password to match the keystore password
with `keytool -keypasswd`, or open an issue to ask for the two-password
case to be added back.

If that env var isn't set: interactively you're asked for it with a hidden
prompt (via `getpass`, never echoed to the terminal and never in shell
history); in `--silent` mode that's a hard error instead.

The password is never written into a child process's *argument list*
(visible to any other process on the machine via a process list). Instead
this script always launches `keytool`/`jarsigner`/`apksigner` with the
password placed in an environment variable private to that one subprocess
call. `keytool`/`jarsigner` (JDK tools) take this as `-storepass:env <VAR>`;
`apksigner` (an Android SDK tool with its own argument conventions) takes
it as `--ks-pass env:<VAR>` instead -- note there's no `pass:` prefix in
front of `env:` for apksigner, unlike the JDK tools.

USAGE
-----
    # Interactive: prompts for anything not supplied.
    python align-and-sign.py --build-dir "C:/build/host-windows-x86_64-target-arm64-android"

    # Silent (CI / CMake custom target): everything supplied up front.
    $env:ANDROID_KEYSTORE_PASSWORD = "..."
    python align-and-sign.py --silent \\
        --build-dir "C:/build/host-windows-x86_64-target-arm64-android" \\
        --keystore-file "./.android-keystore/release.jks" \\
        --key-alias release

See README.md next to this script for the full option reference and the
one-time keystore setup steps.
"""

from __future__ import annotations

import argparse
import getpass
import os
import re
import shutil
import subprocess
import sys
from enum import IntEnum
from pathlib import Path
from typing import Callable, Final, NoReturn, TypeVar

T = TypeVar("T")

# --- Constants ----------------------------------------------------------

KEYSTORE_DIR_NAME: Final[str] = ".android-keystore"
KEYSTORE_SUFFIXES: Final[tuple[str, ...]] = (".jks", ".keystore")
# Default names of the environment variables consulted for each secret; each
# can be pointed elsewhere with --keystore-dir-env/--password-env.
DEFAULT_KEYSTORE_DIR_ENV: Final[str] = "ANDROID_KEYSTORE_DIR"
DEFAULT_PASSWORD_ENV: Final[str] = "ANDROID_KEYSTORE_PASSWORD"
# ``keytool -list -v`` prints one of these lines per key in the store.
ALIAS_RE: Final[re.Pattern[str]] = re.compile(r"^Alias name:\s*(.+)$", re.MULTILINE)
# Env var names used only inside the child-process environment we build for
# each subprocess call -- never written to os.environ / the parent process.
# The same password value is placed in both: see the SECRETS section above.
_KS_PASS_VAR: Final[str] = "_ALIGN_AND_SIGN_KEYSTORE_PASSWORD"
_KEY_PASS_VAR: Final[str] = "_ALIGN_AND_SIGN_KEY_PASSWORD"


class ExitCode(IntEnum):
    """Distinct process exit codes so a CMake custom target (or CI) can tell
    failures apart without scraping stdout."""

    OK = 0
    INVALID_ARGS = 10
    KEYSTORE_DIR_MISSING = 11
    KEYSTORE_FILE_NOT_FOUND = 12
    AMBIGUOUS_SELECTION = 13
    SELECTION_CANCELLED = 14
    KEYSTORE_NO_CERTIFICATES = 15
    MISSING_CREDENTIALS = 16
    BUILD_DIR_MISSING = 17
    NOTHING_TO_SIGN = 18
    TOOL_NOT_FOUND = 19
    SUBPROCESS_FAILED = 20


def die(code: ExitCode, message: str) -> NoReturn:
    """Print ``message`` to stderr and exit the process with ``code``."""
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(int(code))


# --- Repo / project discovery --------------------------------------------


def find_repo_root(explicit: Path | None) -> Path:
    """Return the directory containing the top-level CMakeLists.txt.

    Walks upward from this script's own location when ``explicit`` is not
    given, since the script always lives at a fixed depth under the repo.
    """
    if explicit is not None:
        if not (explicit / "CMakeLists.txt").is_file():
            die(
                ExitCode.INVALID_ARGS,
                f"--repo-root {explicit} has no CMakeLists.txt",
            )
        return explicit
    here: Path = Path(__file__).resolve().parent
    for candidate in (here, *here.parents):
        if (candidate / "CMakeLists.txt").is_file():
            return candidate
    die(
        ExitCode.INVALID_ARGS,
        "could not locate the repo root (no CMakeLists.txt found above "
        "this script); pass --repo-root explicitly",
    )


def parse_project_name(cmakelists: Path) -> str:
    """Extract the name from ``project(<name> ...)`` in CMakeLists.txt."""
    text: str = cmakelists.read_text(encoding="utf-8")
    match: re.Match[str] | None = re.search(
        r"project\s*\(\s*([A-Za-z_][A-Za-z0-9_\-]*)", text
    )
    if match is None:
        die(ExitCode.INVALID_ARGS, f"could not find project(...) in {cmakelists}")
    return match.group(1)


# --- Interactive/silent selection helper ----------------------------------


def select_from_list(
    items: list[T], label: str, to_str: Callable[[T], str], silent: bool
) -> T:
    """Return the single item in ``items``, or ask/require which one to use.

    - Zero items must be handled by the caller before calling this.
    - One item is returned with no prompt in either mode.
    - Multiple items: interactively asks for a 1-based index; in --silent
      mode this is always a hard error (an explicit override is required).
    """
    if len(items) == 1:
        return items[0]
    listing: str = "\n".join(
        f"  [{i}] {to_str(item)}" for i, item in enumerate(items, start=1)
    )
    if silent:
        die(
            ExitCode.AMBIGUOUS_SELECTION,
            f"multiple {label} found and --silent was passed; pass an "
            f"explicit override to disambiguate:\n{listing}",
        )
    print(f"multiple {label} found:")
    print(listing)
    while True:
        choice: str = input(f"select {label} by index (1-{len(items)}): ").strip()
        if not choice:
            die(ExitCode.SELECTION_CANCELLED, f"no {label} selected, aborting")
        if choice.isdigit() and 1 <= int(choice) <= len(items):
            return items[int(choice) - 1]
        print(f"invalid choice: {choice!r}")


def resolve_password(env_name: str, silent: bool) -> str:
    """Resolve the single keystore/key password from an env var, else a
    hidden prompt (used for both -storepass and -keypass, see SECRETS above).
    """
    value: str | None = os.environ.get(env_name)
    if value is not None:
        return value
    if silent:
        die(
            ExitCode.MISSING_CREDENTIALS,
            f"environment variable {env_name!r} is not set (required in --silent mode)",
        )
    return getpass.getpass("keystore/key password: ")


# --- Keystore discovery + certificate check -------------------------------


def discover_keystore(keystore_dir: Path, explicit: Path | None, silent: bool) -> Path:
    if explicit is not None:
        if not explicit.is_file():
            die(
                ExitCode.KEYSTORE_FILE_NOT_FOUND,
                f"--keystore-file not found: {explicit}",
            )
        return explicit
    if not keystore_dir.is_dir():
        die(
            ExitCode.KEYSTORE_DIR_MISSING,
            f"{keystore_dir} does not exist. Create a keystore first, e.g.:\n"
            f"  keytool -genkeypair -v -keystore {keystore_dir / 'release.jks'} "
            "-alias release -keyalg RSA -keysize 8192 -validity 36500 "
            "-storetype PKCS12",
        )
    candidates: list[Path] = sorted(
        p
        for p in keystore_dir.iterdir()
        if p.is_file() and p.suffix.lower() in KEYSTORE_SUFFIXES
    )
    if not candidates:
        die(
            ExitCode.KEYSTORE_FILE_NOT_FOUND,
            f"no .jks/.keystore files found in {keystore_dir}",
        )
    return select_from_list(candidates, "keystore files", lambda p: p.name, silent)


def check_keystore_certificates(keytool: Path, keystore: Path, password: str) -> str:
    """Run ``keytool -list -v`` and return its stdout, or die with the error.

    Also dies if the keystore opens fine but genuinely holds zero entries.
    """
    env: dict[str, str] = {**os.environ, _KS_PASS_VAR: password}
    result: subprocess.CompletedProcess[str] = subprocess.run(
        [
            str(keytool),
            "-list",
            "-v",
            "-keystore",
            str(keystore),
            "-storepass:env",
            _KS_PASS_VAR,
        ],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        die(
            ExitCode.KEYSTORE_NO_CERTIFICATES,
            f"keytool could not read {keystore} (wrong password, or not a "
            f"valid keystore):\n{result.stderr.strip()}",
        )
    if "contains 0 entries" in result.stdout:
        die(ExitCode.KEYSTORE_NO_CERTIFICATES, f"{keystore} contains no certificates")
    print(result.stdout)
    return result.stdout


def extract_aliases(keytool_output: str) -> list[str]:
    return [m.group(1).strip() for m in ALIAS_RE.finditer(keytool_output)]


# --- Tool discovery --------------------------------------------------------


def find_java_tool(name: str) -> Path:
    """Find ``keytool``/``jarsigner`` on PATH, else under $JAVA_HOME/bin."""
    found: str | None = shutil.which(name)
    if found is not None:
        return Path(found)
    java_home: str | None = os.environ.get("JAVA_HOME")
    if java_home is not None:
        exe_name: str = f"{name}.exe" if os.name == "nt" else name
        candidate: Path = Path(java_home) / "bin" / exe_name
        if candidate.is_file():
            return candidate
    die(
        ExitCode.TOOL_NOT_FOUND,
        f"{name} not found on PATH and JAVA_HOME is not set/valid; "
        "install a JDK 17+ and make sure it's on PATH",
    )


def _version_key(path: Path) -> tuple[int, ...]:
    parts: list[int] = []
    for chunk in path.name.split("."):
        if chunk.isdigit():
            parts.append(int(chunk))
        else:
            parts.append(0)
    return tuple(parts) if parts else (0,)


def find_sdk_tool(
    name: str, sdk_root: Path | None, build_tools_version: str | None
) -> Path:
    """Find ``zipalign``/``apksigner`` on PATH, else under the SDK's
    ``build-tools/<version>/`` (highest version by default)."""
    found: str | None = shutil.which(name)
    if found is not None:
        return Path(found)
    root: Path | None = (
        sdk_root
        or _env_path("ANDROID_HOME")
        or _env_path("ANDROID_SDK_ROOT")
    )
    if root is None:
        die(
            ExitCode.TOOL_NOT_FOUND,
            f"{name} not found on PATH; pass --sdk-root or set "
            "ANDROID_HOME/ANDROID_SDK_ROOT",
        )
    build_tools_dir: Path = root / "build-tools"
    if not build_tools_dir.is_dir():
        die(ExitCode.TOOL_NOT_FOUND, f"{build_tools_dir} does not exist")
    version_dir: Path
    if build_tools_version is not None:
        version_dir = build_tools_dir / build_tools_version
    else:
        versions: list[Path] = sorted(
            (p for p in build_tools_dir.iterdir() if p.is_dir()), key=_version_key
        )
        if not versions:
            die(
                ExitCode.TOOL_NOT_FOUND,
                f"no build-tools versions found in {build_tools_dir}",
            )
        version_dir = versions[-1]
    filename: str = f"{name}.bat" if os.name == "nt" and name == "apksigner" else name
    candidate: Path = version_dir / filename
    if not candidate.is_file():
        die(ExitCode.TOOL_NOT_FOUND, f"{candidate} not found")
    return candidate


def _env_path(name: str) -> Path | None:
    value: str | None = os.environ.get(name)
    return Path(value) if value else None


# --- Build-output discovery ------------------------------------------------


def find_apk(
    android_build_dir: Path, explicit: Path | None, silent: bool
) -> Path | None:
    if explicit is not None:
        if not explicit.is_file():
            die(ExitCode.NOTHING_TO_SIGN, f"--apk-file not found: {explicit}")
        return explicit
    outputs_dir: Path = android_build_dir / "build" / "outputs" / "apk"
    if not outputs_dir.is_dir():
        return None
    candidates: list[Path] = sorted(
        p
        for p in outputs_dir.rglob("*.apk")
        if "aligned" not in p.stem.lower() and "-signed" not in p.stem.lower()
    )
    if not candidates:
        return None
    release: list[Path] = [p for p in candidates if "release" in p.stem.lower()]
    pool: list[Path] = release or candidates
    return select_from_list(
        pool,
        "unsigned .apk files",
        lambda p: str(p.relative_to(android_build_dir)),
        silent,
    )


def find_aab(
    android_build_dir: Path, explicit: Path | None, silent: bool
) -> Path | None:
    if explicit is not None:
        if not explicit.is_file():
            die(ExitCode.NOTHING_TO_SIGN, f"--aab-file not found: {explicit}")
        return explicit
    outputs_dir: Path = android_build_dir / "build" / "outputs" / "bundle"
    if not outputs_dir.is_dir():
        return None
    candidates: list[Path] = sorted(
        p for p in outputs_dir.rglob("*.aab") if "-signed" not in p.stem.lower()
    )
    if not candidates:
        return None
    release: list[Path] = [p for p in candidates if "release" in p.stem.lower()]
    pool: list[Path] = release or candidates
    return select_from_list(
        pool,
        ".aab files",
        lambda p: str(p.relative_to(android_build_dir)),
        silent,
    )


# --- Subprocess runner -------------------------------------------------------


def run_tool(
    args: list[str], *, description: str, env: dict[str, str] | None = None
) -> None:
    """Run a signing tool, echo its output, and die on non-zero exit."""
    print(f"$ {' '.join(args)}")
    result: subprocess.CompletedProcess[str] = subprocess.run(
        args, env=env, capture_output=True, text=True, check=False
    )
    if result.stdout:
        sys.stdout.write(result.stdout)
    if result.stderr:
        # jarsigner/zipalign write their normal verbose progress to stderr,
        # so only stderr on an actual failure is treated as an error stream.
        stream = sys.stderr if result.returncode != 0 else sys.stdout
        stream.write(result.stderr)
    if result.returncode != 0:
        die(
            ExitCode.SUBPROCESS_FAILED,
            f"{description} failed with exit code {result.returncode}",
        )


# --- Alignment + signing -----------------------------------------------------


def zip_align(zipalign: Path, src: Path, dest: Path, *, page_align_16kb: bool) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.unlink(missing_ok=True)
    args: list[str] = [str(zipalign), "-v"]
    args += ["-P", "16", "4"] if page_align_16kb else ["-p", "4"]
    args += [str(src), str(dest)]
    run_tool(args, description="zipalign")


def sign_apk(
    apksigner: Path,
    aligned_apk: Path,
    dest: Path,
    *,
    keystore: Path,
    alias: str,
    password: str,
) -> None:
    # apksigner still takes separate --ks-pass/--key-pass flags; Android
    # keystores *can* use two different passwords, but this script follows
    # the common convention of one password for both (see SECRETS above).
    env: dict[str, str] = {
        **os.environ,
        _KS_PASS_VAR: password,
        _KEY_PASS_VAR: password,
    }
    dest.parent.mkdir(parents=True, exist_ok=True)
    run_tool(
        [
            str(apksigner),
            "sign",
            "--ks",
            str(keystore),
            "--ks-key-alias",
            alias,
            "--ks-pass",
            f"env:{_KS_PASS_VAR}",
            "--key-pass",
            f"env:{_KEY_PASS_VAR}",
            "--out",
            str(dest),
            str(aligned_apk),
        ],
        env=env,
        description="apksigner sign",
    )
    run_tool(
        [str(apksigner), "verify", "--print-certs", str(dest)],
        description="apksigner verify",
    )


def sign_aab(
    jarsigner: Path,
    aab_src: Path,
    dest: Path,
    *,
    keystore: Path,
    alias: str,
    password: str,
) -> None:
    env: dict[str, str] = {
        **os.environ,
        _KS_PASS_VAR: password,
        _KEY_PASS_VAR: password,
    }
    dest.parent.mkdir(parents=True, exist_ok=True)
    # jarsigner signs in place, so sign a copy and leave the original alone.
    shutil.copy2(aab_src, dest)
    run_tool(
        [
            str(jarsigner),
            "-verbose",
            "-sigalg",
            "SHA256withRSA",
            "-digestalg",
            "SHA-256",
            "-keystore",
            str(keystore),
            "-storepass:env",
            _KS_PASS_VAR,
            "-keypass:env",
            _KEY_PASS_VAR,
            str(dest),
            alias,
        ],
        env=env,
        description="jarsigner sign",
    )
    run_tool(
        [str(jarsigner), "-verify", "-verbose", "-certs", str(dest)],
        description="jarsigner verify",
    )


# --- CLI ----------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Zip-align and sign the release Android .apk / .aab produced "
            "by a Qt build."
        ),
    )
    parser.add_argument(
        "--repo-root", help="repo root containing CMakeLists.txt (auto-detected)"
    )
    parser.add_argument(
        "--build-dir",
        help="CMake binary dir containing the android-build/ folder",
    )
    parser.add_argument(
        "--output-dir",
        help="where to write signed artifacts (default: <build-dir>/android-build/signed)",
    )
    parser.add_argument(
        "--keystore-dir-env",
        default=DEFAULT_KEYSTORE_DIR_ENV,
        help=(
            "env var name holding the .android-keystore folder path "
            f"(default: {DEFAULT_KEYSTORE_DIR_ENV}; falls back to "
            "<repo-root>/.android-keystore if unset)"
        ),
    )
    parser.add_argument("--keystore-file", help="explicit .jks/.keystore path")
    parser.add_argument("--key-alias", help="signing key alias inside the keystore")
    parser.add_argument(
        "--password-env",
        default=DEFAULT_PASSWORD_ENV,
        help=(
            "env var name holding the keystore/key password, used for both "
            f"(default: {DEFAULT_PASSWORD_ENV}); prompted for interactively "
            "(hidden input) if unset"
        ),
    )

    parser.add_argument("--apk-file", help="explicit unsigned .apk (auto-detected)")
    parser.add_argument("--aab-file", help="explicit .aab (auto-detected)")
    parser.add_argument("--skip-apk", action="store_true", help="do not sign the .apk")
    parser.add_argument("--skip-aab", action="store_true", help="do not sign the .aab")
    parser.add_argument(
        "--sdk-root", help="Android SDK root (overrides ANDROID_HOME/ANDROID_SDK_ROOT)"
    )
    parser.add_argument(
        "--build-tools-version",
        help="specific build-tools version folder (default: highest installed)",
    )
    parser.add_argument(
        "--legacy-alignment",
        action="store_true",
        help="use classic 4-byte zipalign (-p 4) instead of the default 16 KiB "
        "page-aligned mode (-P 16 4) required for apps with native libraries",
    )
    parser.add_argument(
        "--silent",
        action="store_true",
        help="never prompt; fail with a clear error if required input is "
        "missing (use this from a CMake custom target or CI)",
    )
    return parser


def _optional_path(value: object) -> Path | None:
    return Path(str(value)).expanduser().resolve() if value else None


def main() -> int:
    args: argparse.Namespace = build_parser().parse_args()
    silent: bool = bool(args.silent)

    if args.skip_apk and args.skip_aab:
        die(ExitCode.INVALID_ARGS, "--skip-apk and --skip-aab cannot both be set")

    repo_root: Path = find_repo_root(_optional_path(args.repo_root))
    project_name: str = parse_project_name(repo_root / "CMakeLists.txt")
    print(f"project: {project_name}")
    print(f"repo root: {repo_root}")

    build_dir_str: str = str(args.build_dir) if args.build_dir else ""
    if not build_dir_str:
        if silent:
            die(ExitCode.INVALID_ARGS, "--build-dir is required in --silent mode")
        build_dir_str = input("CMake binary dir (contains android-build/): ").strip()
    build_dir: Path = Path(build_dir_str).expanduser().resolve()
    android_build_dir: Path = build_dir / "android-build"
    if not android_build_dir.is_dir():
        die(
            ExitCode.BUILD_DIR_MISSING,
            f"{android_build_dir} does not exist; build the Android target first",
        )

    output_dir: Path = _optional_path(args.output_dir) or (
        android_build_dir / "signed"
    )

    keystore_dir_override: str | None = os.environ.get(str(args.keystore_dir_env))
    keystore_dir: Path = (
        Path(keystore_dir_override).expanduser().resolve()
        if keystore_dir_override
        else repo_root / KEYSTORE_DIR_NAME
    )
    keystore: Path = discover_keystore(
        keystore_dir, _optional_path(args.keystore_file), silent
    )
    print(f"keystore: {keystore}")

    password: str = resolve_password(str(args.password_env), silent)

    keytool: Path = find_java_tool("keytool")
    cert_output: str = check_keystore_certificates(keytool, keystore, password)

    alias: str | None = str(args.key_alias) if args.key_alias else None
    if alias is None:
        aliases: list[str] = extract_aliases(cert_output)
        if not aliases:
            die(
                ExitCode.KEYSTORE_NO_CERTIFICATES,
                f"could not find any key alias in {keystore}",
            )
        alias = select_from_list(aliases, "key aliases", lambda a: a, silent)
    print(f"key alias: {alias}")

    signed_anything: bool = False


    if not bool(args.skip_apk):
        apk: Path | None = find_apk(android_build_dir, _optional_path(args.apk_file), silent)
        if apk is None:
            print(
                "no unsigned .apk found under "
                f"{android_build_dir / 'build' / 'outputs' / 'apk'}; "
                "build the Android target first.",
                file=sys.stderr,
            )
        else:
            print(f"apk: {apk}")
            sdk_root: Path | None = _optional_path(args.sdk_root)
            build_tools_version: str | None = (
                str(args.build_tools_version) if args.build_tools_version else None
            )
            zipalign: Path = find_sdk_tool("zipalign", sdk_root, build_tools_version)
            apksigner: Path = find_sdk_tool("apksigner", sdk_root, build_tools_version)
            aligned: Path = output_dir / f"{project_name}-release-aligned-unsigned.apk"
            signed_apk: Path = output_dir / f"{project_name}-release-aligned-signed.apk"
            zip_align(
                zipalign, apk, aligned, page_align_16kb=not bool(args.legacy_alignment)
            )
            sign_apk(
                apksigner,
                aligned,
                signed_apk,
                keystore=keystore,
                alias=alias,
                password=password,
            )
            aligned.unlink(missing_ok=True)
            print(f"signed apk -> {signed_apk}")
            signed_anything = True

    if not bool(args.skip_aab):
        aab: Path | None = find_aab(android_build_dir, _optional_path(args.aab_file), silent)
        if aab is None:
            print(
                "no .aab found under "
                f"{android_build_dir / 'build' / 'outputs' / 'bundle'}; "
                "run the CMake 'aab' target first.",
                file=sys.stderr,
            )
        else:
            print(f"aab: {aab}")
            jarsigner: Path = find_java_tool("jarsigner")
            signed_aab: Path = output_dir / f"{project_name}-release-signed.aab"
            sign_aab(
                jarsigner,
                aab,
                signed_aab,
                keystore=keystore,
                alias=alias,
                password=password,
            )
            print(f"signed aab -> {signed_aab}")
            signed_anything = True

    if not signed_anything:
        die(
            ExitCode.NOTHING_TO_SIGN,
            "nothing was signed; no apk/aab found (and neither was --skip-*'d)",
        )

    return int(ExitCode.OK)


if __name__ == "__main__":
    raise SystemExit(main())
