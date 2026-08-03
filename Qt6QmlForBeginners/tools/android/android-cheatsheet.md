# Android Post-Build Cheatsheet

Everything you need after `.apk`/`.aab` files come out of your build: create a
keystore, sign and align the APK, sign the AAB, set up the emulator on
Windows from the command line only, create an AVD, then launch/install/debug.

Every command below explains **every flag it uses** — nothing is left as
"you'll figure it out."

---

## 0. Prerequisites

| Tool | Why you need it | Where it comes from |
|---|---|---|
| JDK 17+ | `keytool`, `jarsigner` ship with the JDK | Install a JDK (Temurin, Oracle, etc.) and make sure `java`/`keytool` are on `PATH` |
| Android cmdline-tools | `sdkmanager`, `avdmanager`, `apksigner`, `zipalign` | Set up in [Part B](#part-b-install-the-android-sdk-cmdline-tools-on-windows) below |
| `adb` (platform-tools) | Install/launch apps, logcat | Installed via `sdkmanager` in Part B |

Set one environment variable before anything else — everything else in this
guide assumes it exists:

```powershell
setx ANDROID_HOME "C:\Android\sdk"
```

- `setx` — Windows command to set a **persistent** environment variable
  (survives terminal restarts, unlike `set`).
- `ANDROID_HOME` — the conventional variable name every Android tool
  (`sdkmanager`, Gradle, Android Studio) looks for to find your SDK.
- **Close and reopen your terminal** after `setx` — it doesn't apply to the
  terminal you ran it in.

---

## Part A — Signing what you already built

### A1. Create a keystore + signing key

```powershell
keytool -genkeypair -v -keystore my-release-key.jks -alias my-key-alias -keyalg RSA -keysize 2048 -validity 36500 -storetype PKCS12
```

| Flag | Meaning |
|---|---|
| `-genkeypair` | Generates a new public/private key pair (the modern replacement for the older `-genkey`) |
| `-v` | Verbose output — prints what it's doing |
| `-keystore my-release-key.jks` | Path/filename of the keystore file to create. You'll be prompted to set a **keystore password** — remember it, you need it for every future signing operation and can never recover it if lost |
| `-alias my-key-alias` | A name for this specific key *inside* the keystore (a keystore can hold multiple keys). You'll reference this alias every time you sign |
| `-keyalg RSA` | The key algorithm — RSA is what Android expects |
| `-keysize 2048` | Key length in bits. 2048 is the standard/minimum accepted size |
| `-validity 36500` | How many **days** the certificate is valid for (~27 years). Google Play requires your signing cert to be valid past **October 22, 2033** at minimum, so a large number like this is intentional, not excessive |
| `-storetype PKCS12` | The keystore file format. `PKCS12` is the modern default (industry-standard, works with any tool); the old `JKS` format is Java-proprietary and considered legacy. Extension can still be `.jks` — the `-storetype` flag is what actually determines the format, not the file extension |

After running this you'll be interactively prompted for:
1. Keystore password (set it, then confirm it)
2. Your name / org / city / country (used to populate the certificate — can be anything for a personal project, but be accurate for anything published)
3. Key password — you can just press Enter to reuse the keystore password

**Keep `my-release-key.jks` and both passwords somewhere safe and backed up.**
If you lose it, you can never publish an update to an app already on Google
Play under that signing key.

To check what's inside a keystore later:

```powershell
keytool -list -v -keystore my-release-key.jks
```

- `-list` — lists the keys/certificates in the keystore
- `-v` — verbose (shows full certificate fingerprints, validity dates, etc.)

---

### A2. Zip-align the APK

> **Order matters.** With `apksigner` (the tool you should be using — see
> A3), **zipalign must run *before* signing.** If you zipalign an already
> `apksigner`-signed APK, you invalidate its signature, because the v2/v3
> signing schemes cover the entire file including its alignment. (This is
> the *opposite* of the old `jarsigner` workflow, which is why so many
> outdated tutorials get the order backwards.)

```powershell
zipalign -v -p 4 app-unsigned.apk app-unsigned-aligned.apk
```

| Flag | Meaning |
|---|---|
| `-v` | Verbose output |
| `-p` | Also page-align any `.so` (native library) files inside the APK to a 4 KiB boundary, not just the default 4-byte alignment. Needed if your app ships native code |
| `4` | The **required** alignment value for the general zip alignment (always `4`, i.e. 32-bit alignment — this isn't optional or a size you choose) |
| `app-unsigned.apk` | Your input APK (before alignment) |
| `app-unsigned-aligned.apk` | Where to write the aligned output |

**If your app ships native `.so` libraries, use 16 KiB page alignment
instead** — required by Google Play as of the 16 KB memory page size policy:

```powershell
zipalign -v -P 16 4 app-unsigned.apk app-unsigned-aligned.apk
```

- `-P 16` — page-align native libraries to a **16 KiB** boundary (capital
  `P`, distinct from lowercase `-p`) instead of the older 4 KiB. This is
  required for compatibility with modern 16 KB-page devices; apps with
  native code that aren't 16 KB-aligned can be rejected by Play Console.
- The trailing `4` is still required — it's the general alignment value,
  independent of the `-P 16` native-library alignment.

To verify an APK's alignment without modifying it:

```powershell
zipalign -c -v -P 16 4 app.apk
```

- `-c` — **c**heck alignment only, don't write an output file. Exits with an
  error if anything isn't aligned correctly.

---

### A3. Sign the APK

```powershell
apksigner sign --ks my-release-key.jks --ks-key-alias my-key-alias --out app-release.apk app-unsigned-aligned.apk
```

| Flag | Meaning |
|---|---|
| `sign` | The apksigner subcommand — signs an APK |
| `--ks my-release-key.jks` | Path to the keystore created in A1 |
| `--ks-key-alias my-key-alias` | Which key inside the keystore to use (matches `-alias` from A1) |
| `--out app-release.apk` | Filename for the final, signed APK |
| `app-unsigned-aligned.apk` | The (already zip-aligned) input APK from A2 |

You'll be prompted for the keystore password, then the key password (if
different).

**Optional but recommended flags:**

| Flag | Meaning |
|---|---|
| `--ks-pass pass:yourpassword` | Supply the keystore password non-interactively (useful in CI). Avoid hardcoding real passwords in scripts — use `pass:env:VAR_NAME` to read from an environment variable instead |
| `--v1-signing-enabled true/false` | Whether to include the legacy JAR signature scheme (v1). Needed only if you must support very old Android versions (< 7.0) |
| `--v2-signing-enabled true` | APK Signature Scheme v2 (default on, don't usually need to set explicitly) |

Verify the signature afterward:

```powershell
apksigner verify --print-certs app-release.apk
```

- `verify` — checks the APK's signature is valid
- `--print-certs` — also prints certificate details (fingerprint, etc.) so
  you can confirm it matches the key you expect

---

### A4. Sign the AAB (Android App Bundle)

AABs are signed with `jarsigner`, **not** `apksigner` (which only
understands the APK format). **No zipalign step is needed for an AAB** —
alignment is an APK-installation concern; Play Console generates properly
aligned APKs from your bundle automatically.

```powershell
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore my-release-key.jks app-release.aab my-key-alias
```

| Flag | Meaning |
|---|---|
| `-verbose` | Prints detailed signing output |
| `-sigalg SHA256withRSA` | Signature algorithm — SHA-256 with RSA is the current recommended standard (older defaults like SHA1 are weaker and increasingly rejected) |
| `-digestalg SHA-256` | Hash algorithm used for each file's digest inside the archive |
| `-keystore my-release-key.jks` | Same keystore from A1 |
| `app-release.aab` | The AAB file to sign — **signed in place**, unlike `apksigner` there's no separate `--out` |
| `my-key-alias` | The key alias to use (positional argument, no flag) |

Verify it:

```powershell
jarsigner -verify -verbose -certs app-release.aab
```

- `-verify` — check the signature instead of creating one
- `-certs` — print certificate details alongside verification output

**Optional: test your signed AAB locally before uploading to Play Console**
using `bundletool` (a separate download from Google, not part of
cmdline-tools):

```powershell
bundletool build-apks --bundle=app-release.aab --output=app.apks --ks=my-release-key.jks --ks-key-alias=my-key-alias --mode=universal
bundletool install-apks --apks=app.apks
```

- `build-apks` — converts the `.aab` into a set of installable `.apk`s
  (what Play Console does server-side)
- `--mode=universal` — produce one single APK containing all
  device configs/languages, instead of Play's normal per-device splitting
  (much simpler for local testing)
- `install-apks` — installs the generated `.apks` onto a connected
  device/emulator directly, no Play Store involved

---

## Part B — Install the Android SDK cmdline-tools on Windows

You want the SDK tools available without installing all of Android Studio.

### B1. Download and place the tools

1. Download **"Command line tools only"** for Windows from
   `https://developer.android.com/studio#command-line-tools-only`
2. Create the SDK root folder and a `cmdline-tools` subfolder inside it:

```powershell
mkdir C:\Android\sdk\cmdline-tools
```

3. Extract the downloaded zip. It contains a folder named `cmdline-tools`
   with `bin/`, `lib/`, etc. inside. **Rename that inner folder to `latest`**
   and move it in, so you end up with exactly:

```
C:\Android\sdk\cmdline-tools\latest\bin\sdkmanager.bat
C:\Android\sdk\cmdline-tools\latest\bin\avdmanager.bat
```

> This exact path structure (`cmdline-tools\latest\...`) matters —
> `sdkmanager` refuses to run correctly if the tools sit directly in
> `cmdline-tools\` without the `latest` subfolder.

### B2. Add the tools to `PATH`

```powershell
setx PATH "%PATH%;C:\Android\sdk\cmdline-tools\latest\bin;C:\Android\sdk\platform-tools;C:\Android\sdk\emulator"
```

- Adds `sdkmanager`/`avdmanager` (cmdline-tools), `adb` (platform-tools —
  installed next), and `emulator` to your `PATH` so you can call them from
  any folder.
- **Close and reopen your terminal** for this to take effect.

### B3. Accept licenses and install core packages

```powershell
sdkmanager --licenses
```

- `--licenses` — walks through every SDK license you haven't yet accepted,
  prompting `y`/`n` for each. Type `y` for all of them (usually ~6–7
  prompts).

```powershell
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "emulator"
```

- `"platform-tools"` — installs `adb`, `fastboot`
- `"platforms;android-35"` — the Android 15 (API 35) platform SDK. Swap the
  number for whichever API level you're targeting; check what's current with
  `sdkmanager --list`
- `"build-tools;35.0.0"` — version-matched build tools including
  `zipalign` and `apksigner` used in Part A
- `"emulator"` — the actual Android Emulator binary

```powershell
sdkmanager "system-images;android-35;google_apis;x86_64"
```

- A **system image** is the actual Android OS image an AVD boots. Format is
  `system-images;<api>;<variant>;<abi>`:
  - `google_apis` — includes Google Play Services APIs (but not the Play
    Store app itself) — the most common choice for development
  - `google_apis_playstore` — same, plus the real Play Store app, if you
    need to test in-app purchases/Play features
  - `x86_64` — the ABI. Use `x86_64` on Intel/AMD Windows machines for a
    fast, hardware-accelerated emulator. Use `arm64-v8a` only if you're on
    an ARM host (not typical for Windows PCs)

To check what's already installed vs. available:

```powershell
sdkmanager --list
```

To update everything you've installed to the latest versions:

```powershell
sdkmanager --update
```

---

## Part C — Create an AVD (Android Virtual Device)

First, see what device hardware profiles are available:

```powershell
avdmanager list device
```

Prints an ID and name for each profile (e.g. `pixel_7`, `pixel_tablet`).
You'll pass one of these names to `--device` below.

Create the AVD:

```powershell
avdmanager create avd --name Pixel7_API35 --package "system-images;android-35;google_apis;x86_64" --device pixel_7
```

| Flag | Meaning |
|---|---|
| `create avd` | The avdmanager subcommand — creates a new virtual device |
| `--name Pixel7_API35` | Whatever you want to call this AVD — used later to launch it |
| `--package "system-images;..."` | Which system image (installed in B3) this AVD boots |
| `--device pixel_7` | Which hardware profile (screen size, DPI, buttons) to emulate — from `avdmanager list device` |

If it prompts `Do you wish to create a custom hardware profile? [no]`, just
press Enter to accept the default (`no`) unless you specifically want to
customize RAM/storage/etc. at creation time.

**Optional flags:**

| Flag | Meaning |
|---|---|
| `--force` | Overwrite an existing AVD with the same `--name` instead of erroring |
| `--sdcard 512M` | Creates a virtual SD card of the given size for the AVD |
| `--abi x86_64` | Explicitly pin the ABI if a package string is ambiguous |

List your AVDs at any time:

```powershell
avdmanager list avd
```

Delete one if needed:

```powershell
avdmanager delete avd --name Pixel7_API35
```

---

## Part D — Launch, install, and debug

### D1. Launch the emulator

```powershell
emulator -avd Pixel7_API35 -netdelay none -netspeed full
```

| Flag | Meaning |
|---|---|
| `-avd Pixel7_API35` | Which AVD to boot (matches `--name` from Part C) |
| `-netdelay none` | Simulate zero network latency (default emulates a slower mobile connection) |
| `-netspeed full` | Simulate full-speed network instead of a throttled mobile connection |

**Other useful flags:**

| Flag | Meaning |
|---|---|
| `-no-snapshot-load` | Boot fresh instead of resuming from the last saved emulator state — use this if the emulator seems stuck/corrupted |
| `-no-boot-anim` | Skip the boot animation, boots slightly faster |
| `-wipe-data` | Reset the AVD to a factory-fresh state, erasing all installed apps/data |
| `-gpu host` | Use your PC's real GPU for rendering (faster) instead of software rendering — try this if graphics are slow |
| `-writable-system` | Mount the system partition as writable (needed for some advanced debugging, e.g. installing certs as system-trusted) |

List running/available AVDs without launching one:

```powershell
emulator -list-avds
```

### D2. Confirm the device is connected

```powershell
adb devices
```

- Lists all connected devices/emulators with their serial IDs (e.g.
  `emulator-5554`) and status (`device`, `offline`, `unauthorized`).
  Run this after booting to confirm the emulator is actually reachable
  before trying to install anything.

If you have multiple devices/emulators connected at once, target a specific
one in any `adb` command with `-s <serial>`, e.g. `adb -s emulator-5554 install ...`.

### D3. Install the APK

```powershell
adb install -r app-release.apk
```

| Flag | Meaning |
|---|---|
| `install` | The adb subcommand to install an APK |
| `-r` | **R**eplace an existing install of the same app, keeping its data (instead of erroring "already installed") |
| `app-release.apk` | Path to your signed APK from A3 |

**Other useful flags:**

| Flag | Meaning |
|---|---|
| `-d` | Allow a **d**owngrade install (installing an older `versionCode` over a newer one) — normally blocked |
| `-g` | **G**rant all runtime permissions automatically on install, instead of the app prompting for each at first use |
| `-t` | Allow installing an APK marked as a **t**est package |

### D4. Launch the app

```powershell
adb shell am start -n com.example.myapp/.MainActivity
```

| Part | Meaning |
|---|---|
| `shell` | Run a command inside the device/emulator's shell rather than on your PC |
| `am start` | **A**ctivity **m**anager command to start an activity/app |
| `-n com.example.myapp/.MainActivity` | The **n**ame of the component to launch, as `<package>/<Activity class>`. The leading `.` means "relative to the package name" |

Not sure of your launch activity's exact name? Use the launcher intent
instead, which finds it automatically:

```powershell
adb shell monkey -p com.example.myapp -c android.intent.category.LAUNCHER 1
```

- `monkey` — normally a stress-testing tool, but sending it exactly `1`
  event is a convenient way to just launch an app by package name without
  knowing the activity class
- `-p com.example.myapp` — the target package
- `-c android.intent.category.LAUNCHER 1` — restrict to the app's main
  launcher intent, and send exactly `1` event (i.e. "just open it")

### D5. View logs (logcat)

```powershell
adb logcat
```

Streams all device log output continuously (Ctrl+C to stop). In practice
you almost always want to filter it:

```powershell
adb logcat -v time *:E
```

| Flag | Meaning |
|---|---|
| `-v time` | Log output **v**erbosity/format — `time` prefixes each line with a timestamp |
| `*:E` | Filter spec: `*` = all tags, `E` = **E**rror level and above only (silences Verbose/Debug/Info/Warn noise) |

**Other useful filters/flags:**

| Flag | Meaning |
|---|---|
| `-c` | **C**lear the log buffer before starting (useful to get a clean slate before reproducing a bug) |
| `MyTag:D *:S` | Show Debug+ level for `MyTag` only, **S**ilence (suppress) everything else — good for focusing on your own app's logs |
| `-d` | **D**ump the current log and exit immediately, instead of streaming live — useful for grabbing a snapshot into a file |
| `> log.txt` | (shell redirection, not an adb flag) pipe output to a file, e.g. `adb logcat -d > log.txt` |

To filter to just your app's process:

```powershell
adb logcat --pid=$(adb shell pidof -s com.example.myapp)
```

- `pidof -s com.example.myapp` — looks up the running process ID for your
  app's package name
- `--pid=<id>` — restricts logcat output to only that process

---

## Quick reference — the whole pipeline in order

```powershell
:: A) Sign what you built
keytool -genkeypair -v -keystore my-release-key.jks -alias my-key-alias -keyalg RSA -keysize 2048 -validity 36500 -storetype PKCS12
zipalign -v -P 16 4 app-unsigned.apk app-unsigned-aligned.apk
apksigner sign --ks my-release-key.jks --ks-key-alias my-key-alias --out app-release.apk app-unsigned-aligned.apk
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore my-release-key.jks app-release.aab my-key-alias

:: B) One-time SDK setup
sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "emulator"
sdkmanager "system-images;android-35;google_apis;x86_64"

:: C) One-time AVD setup
avdmanager create avd --name Pixel7_API35 --package "system-images;android-35;google_apis;x86_64" --device pixel_7

:: D) Every time you test
emulator -avd Pixel7_API35
adb devices
adb install -r app-release.apk
adb shell monkey -p com.example.myapp -c android.intent.category.LAUNCHER 1
adb logcat -v time *:E
```

---

## Troubleshooting quick hits

| Symptom | Likely fix |
|---|---|
| `'sdkmanager' is not recognized...` | `PATH` wasn't updated correctly, or you didn't reopen the terminal after `setx` |
| `zipalign`/`apksigner` not found | They live in `build-tools;<version>` — add `C:\Android\sdk\build-tools\<version>` to `PATH` too, or call them with their full path |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | The installed app was signed with a different key than the one you're installing now — uninstall first (`adb uninstall com.example.myapp`), or make sure you're using the same keystore/alias |
| Emulator boots but is very slow | Add `-gpu host`; also confirm hardware virtualization (Intel HAXM / Windows Hypervisor Platform) is enabled in BIOS |
| `adb devices` shows nothing | Emulator may still be booting — wait, or run `adb kill-server` then `adb start-server` and check again |
