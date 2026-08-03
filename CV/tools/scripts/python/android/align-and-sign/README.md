# Android Align & Sign — Usage Guide

Zip-align and sign the release `.apk` / `.aab` a Qt-for-Android build
produces, using a keystore you already created. Works standalone from a
terminal, or as a silent CMake custom target. The script source is
**heavily commented** — read `align-and-sign.py` top-to-bottom to see what
each line does.

```
python align-and-sign.py --build-dir "C:/build/host-windows-x86_64-target-arm64-android"
```

---

## 1. What you need

| Thing | Why | Notes |
|-------|-----|-------|
| **Python 3.11+** | Runs the script | Standard library only — no `pip install` needed |
| **JDK 17+** | `keytool` / `jarsigner` | Must be on `PATH`, or set `JAVA_HOME` |
| **Android SDK build-tools** | `zipalign` / `apksigner` | Must be on `PATH`, or set `ANDROID_HOME`/`ANDROID_SDK_ROOT` (see `tools/android/android-cheatsheet.md`) |
| **A signing keystore** | Signs the release build | A `.jks`/`.keystore` file under `<repo-root>/.android-keystore/` (see below) |
| **A built `.apk` and/or `.aab`** | The files this script signs | Produced by a normal CMake/Qt Android build (`.apk`) and the CMake `aab` target (`.aab`) |

The script itself has **zero third-party dependencies** — it only uses the
Python standard library (`argparse`, `subprocess`, `pathlib`, ...) to drive
`keytool`, `zipalign`, `apksigner`, and `jarsigner`.

---

## 2. One-time keystore setup

Create a folder named exactly `.android-keystore` in the repo root (next to
`CMakeLists.txt`) and generate a key inside it:

```powershell
mkdir .android-keystore
keytool -genkeypair -v -keystore .android-keystore\release.jks -alias release -keyalg RSA -keysize 8192 -validity 36500 -storetype PKCS12
```

Full explanation of every flag is in `tools/android/android-cheatsheet.md`
(section A1). **Back up this file and its passwords** — losing them means
you can never publish an update under the same signing identity.

By default the script looks for that folder at `<repo-root>/.android-keystore/`.
To use a different location (handy for CI, where the keystore isn't checked
into the repo), point the `ANDROID_KEYSTORE_DIR` environment variable
(or whatever name you pass to `--keystore-dir-env`) at it instead:

```powershell
$env:ANDROID_KEYSTORE_DIR = "D:/secrets/android-keystore"
```

The script scans that folder for `*.jks`/`*.keystore` files:

- **Exactly one file** → used automatically, no prompt.
- **Multiple files** → interactive mode asks which one (prints an indexed
  list); `--silent` mode fails and tells you to pass `--keystore-file`.
- **No folder / no files** → the script prints the exact `keytool` command
  above and exits.

The same auto-detect-or-ask behaviour applies to the **key alias**: if the
keystore holds only one alias it's used automatically; otherwise you're
asked (interactive) or must pass `--key-alias` (`--silent`).

---

## 3. The two modes

### Interactive (default)

Anything not supplied on the command line is asked for on the terminal:
which build dir, which keystore file, which alias. Passwords are read from
an environment variable if it's set; otherwise you're asked for them with a
hidden `getpass` prompt — nothing is echoed to the terminal and nothing
ends up in shell history.

```powershell
python align-and-sign.py --build-dir "C:/build/host-windows-x86_64-target-arm64-android"
```

### Silent (`--silent`) — for CMake / CI

Never prompts. Every required value must be resolvable from a flag or an
environment variable; anything missing is a hard error with a specific
non-zero exit code (see [Exit codes](#6-exit-codes)) instead of hanging on
an `input()` call.

```powershell
$env:ANDROID_KEYSTORE_PASSWORD = "..."
python align-and-sign.py --silent `
    --build-dir "C:/build/host-windows-x86_64-target-arm64-android" `
    --keystore-file ".android-keystore/release.jks" `
    --key-alias release
```

---

## 4. The password, handled safely

Every argument is a `--named-flag` — there is no positional/order-dependent
argument, so any of them can be reordered or omitted.

Android keystores technically support two independent passwords — one for
the keystore file, one for the key alias inside it — but the near-universal
convention (and what `keytool -genkeypair` does when you just press Enter
at the key-password prompt) is to reuse the keystore password as the key
password too. This script follows that convention: there is exactly **one**
password, read from a single environment variable named by
`--password-env` (defaulting to `ANDROID_KEYSTORE_PASSWORD`, so you usually
don't need to pass this flag at all — just set the env var). There is no
`--password`/`--keystore-pass` literal-value flag, so a plaintext password
can never end up in your shell history. If your keystore genuinely uses two
different passwords, use `keytool -keypasswd` to make them match first.

- If the env var **is** set, its value is used, in both modes.
- If it is **not** set: interactively, you're asked for it with a hidden
  `getpass` prompt (nothing echoed to the terminal); in `--silent` mode,
  that's a hard error.
- Whichever way the password is obtained, it is never passed as a literal
  `.apk`/`.aab`-signing subprocess argument — it's placed into a variable
  inside a private environment map handed only to that one
  `keytool`/`jarsigner`/`apksigner` call. `keytool`/`jarsigner` read it via
  `-storepass:env <VAR>`; `apksigner` uses its own convention,
  `--ks-pass env:<VAR>` (no `pass:` prefix in front of `env:` there).
  This means the plaintext password never appears in a process listing on
  the machine.

---

## 5. What gets produced

| Input | Tool chain | Output |
|-------|-----------|--------|
| `android-build/build/outputs/apk/**/*.apk` (unsigned, release) | `zipalign` (16 KiB page-aligned by default) → `apksigner sign` → `apksigner verify` | `<build-dir>/android-build/signed/<Project>-release-aligned-signed.apk` |
| `android-build/build/outputs/bundle/**/*.aab` | copy → `jarsigner` (signs in place) → `jarsigner -verify` | `<build-dir>/android-build/signed/<Project>-release-signed.aab` |

`<Project>` is read directly out of `project(...)` in the repo's root
`CMakeLists.txt`, so the signed file names always match the app.

If the `.apk` isn't there yet, the script tells you to build the Android
target first. If the `.aab` isn't there yet, it tells you to run the
CMake `aab` target first. Either one can be skipped explicitly with
`--skip-apk` / `--skip-aab` (not both at once).

### Zip-align mode

By default the script uses `zipalign -P 16 4` (16 KiB native-library page
alignment), which Google Play requires for apps shipping native `.so`
libraries — true for any Qt app. Pass `--legacy-alignment` to fall back to
the older `zipalign -p 4` (4-byte) mode if you specifically need it.

---

## 6. Exit codes

Each failure mode has its own exit code, so a CMake custom target or CI
step can tell exactly what went wrong without parsing stdout:

| Code | Meaning |
|------|---------|
| `0` | Success |
| `10` | Invalid combination of arguments |
| `11` | `.android-keystore/` folder doesn't exist |
| `12` | Given/found keystore file doesn't exist |
| `13` | Multiple candidates found and `--silent` was passed (needs an explicit override) |
| `14` | Interactive selection was cancelled (empty input) |
| `15` | Keystore has no certificates, or the password was wrong |
| `16` | The password's env var is missing (silent mode) |
| `17` | `<build-dir>/android-build/` doesn't exist |
| `18` | Nothing was signed (no `.apk`/`.aab` found, and neither was skipped) |
| `19` | `keytool`/`jarsigner`/`zipalign`/`apksigner` not found |
| `20` | A signing subprocess itself failed (its own stderr is printed first) |

---

## 7. Full CLI reference

```
python align-and-sign.py [--repo-root DIR] [--build-dir DIR] [--output-dir DIR]
                          [--keystore-dir-env VAR] [--keystore-file FILE]
                          [--key-alias ALIAS] [--password-env VAR]
                          [--apk-file FILE] [--aab-file FILE]
                          [--skip-apk] [--skip-aab]
                          [--sdk-root DIR] [--build-tools-version VERSION]
                          [--legacy-alignment] [--silent]
```

| Flag | Default | Meaning |
|------|---------|---------|
| `--repo-root` | auto-detected | Repo root containing `CMakeLists.txt` |
| `--build-dir` | — | CMake binary dir containing `android-build/`. Required (or prompted for interactively) |
| `--output-dir` | `<build-dir>/android-build/signed` | Where to write signed artifacts |
| `--keystore-dir-env` | `ANDROID_KEYSTORE_DIR` | Env var holding the `.android-keystore` folder path (falls back to `<repo-root>/.android-keystore`) |
| `--keystore-file` | auto-detected under the keystore dir | Explicit keystore path |
| `--key-alias` | auto-detected if the keystore has one alias | Signing key alias |
| `--password-env` | `ANDROID_KEYSTORE_PASSWORD`; prompted if unset (interactive) | Env var holding the keystore/key password (used for both) |
| `--apk-file` | auto-detected under `android-build/build/outputs/apk/` | Explicit unsigned `.apk` |
| `--aab-file` | auto-detected under `android-build/build/outputs/bundle/` | Explicit `.aab` |
| `--skip-apk` | off | Don't sign the `.apk` |
| `--skip-aab` | off | Don't sign the `.aab` |
| `--sdk-root` | `ANDROID_HOME`/`ANDROID_SDK_ROOT` | Android SDK root, for locating `zipalign`/`apksigner` |
| `--build-tools-version` | highest installed | Pin a specific `build-tools/<version>/` folder |
| `--legacy-alignment` | off (16 KiB page-aligned) | Use classic 4-byte `zipalign -p 4` |
| `--silent` | off | Never prompt; every required value must resolve from a flag/env var |

---

## 8. Using it as a CMake custom target

Add a target that calls the script in `--silent` mode, reading the
password from an environment variable set outside CMake (never bake real
secrets into `CMakeCache.txt`):

```cmake
if(ANDROID)
  find_package(Python3 COMPONENTS Interpreter)
  if(Python3_FOUND)
    add_custom_target(
      android_align_and_sign
      COMMAND
        ${Python3_EXECUTABLE}
        ${CMAKE_SOURCE_DIR}/tools/scripts/python/android/align-and-sign/align-and-sign.py
        --silent
        --repo-root ${CMAKE_SOURCE_DIR}
        --build-dir ${CMAKE_BINARY_DIR}
        --password-env ANDROID_KEYSTORE_PASSWORD
      COMMENT "Zip-aligning and signing the Android apk/aab"
      USES_TERMINAL
      VERBATIM
    )
  endif()
endif()
```

Then, after building the `apk`/`aab` outputs:

```powershell
$env:ANDROID_KEYSTORE_PASSWORD = "..."
cmake --build . --target android_align_and_sign
```

A non-zero exit code (see the table above) fails the CMake build step the
same way any other custom command failure would, and the script's own
stdout/stderr (including the underlying `keytool`/`apksigner`/`jarsigner`
output) is shown inline because of `USES_TERMINAL`.
