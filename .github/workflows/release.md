# Release workflow

The release workflow is [release.yml](release.yml). It runs when a tag matching `*-v*-release` is pushed.

## Why the workflow uses native runners

GitHub-hosted Docker containers are available for Linux jobs, but they cannot provide a hosted macOS runner with Xcode or a hosted Windows runner with MSVC. The workflow therefore uses native runners:

| Job | Runner | Preset | Output |
|---|---|---|---|
| `host-x64-windows-target-x64-windows-static-release` | `windows-latest` | `host-x64-windows-target-x64-windows-static-release` | ZIP and NSIS `.exe` |
| `host-arm64-windows-target-arm64-windows-static-release` | `windows-11-arm` | `host-arm64-windows-target-arm64-windows-static-release` | ZIP and NSIS `.exe` |
| `host-arm64-osx-target-arm64-osx-release` | `macos-latest` | `host-arm64-osx-target-arm64-osx-release` | DMG and TGZ |
| `host-arm64-osx-target-arm64-ios-simulator-release` | `macos-latest` | `host-arm64-osx-target-arm64-ios-simulator-release` / `host-arm64-osx-target-arm64-ios-simulator-release-build` | unsigned arm64 iOS Simulator `.app` ZIP |
| `host-arm64-osx-target-arm64-ios-release` | `macos-latest` | `host-arm64-osx-target-arm64-ios-release` (configure only; archive uses direct Xcode tooling) | unsigned `.xcarchive`, or signed IPA when secrets exist |
| `host-x64-linux-target-x64-linux-release` | `ubuntu-26.04` | `host-x64-linux-target-x64-linux-release` | DEB, TGZ |
| `host-arm64-linux-target-arm64-linux-release` | `ubuntu-26.04-arm` | `host-arm64-linux-target-arm64-linux-release` | DEB, TGZ |
| `host-x64-windows-target-arm64-android-release` | `windows-latest` | `host-x64-windows-target-arm64-android-release` | aligned/signed APK and AAB |
| `host-x64-windows-target-wasm32-emscripten-release` | `windows-latest` | `host-x64-windows-target-wasm32-emscripten-release` | HTML, JavaScript, WASM and assets |

The Linux arm64 release job uses a native arm64 Ubuntu runner with the static `host-arm64-linux-target-arm64-linux-release` preset. It builds the arm64 binary natively and publishes DEB/TGZ packages. It does not invoke linuxdeploy because this workflow intentionally uses only static vcpkg triplets.

## Common setup commands

Each platform build job performs the common dependency setup below:

1. `actions/checkout@v7` checks out the tag commit.
2. `lukka/get-cmake@latest` supplies a current CMake release. The project requires CMake 4.4.2 or newer.
3. The macOS jobs install Homebrew `autoconf`, `autoconf-archive`, `automake`, `libtool`, and `ninja`, while both Linux jobs install the equivalent Debian packages. These tools are required by vcpkg ports such as `gperf` and `libb2`; Ninja is the generator required by the Apple Multi-Config presets.
4. `git clone https://github.com/microsoft/vcpkg.git` downloads vcpkg.
5. `git checkout eb2d3a3279fd019cb7733072d86900d0ad2a1aef` selects the baseline pinned in `vcpkg-configuration.json` and the workflow environment.
6. `bootstrap-vcpkg` builds the vcpkg executable without telemetry.
7. `BUILD_ROOT`, `VCPKG_ROOT`, `VCPKG_INSTALLED_ROOT`, and `VCPKG_BUILDTREES_ROOT` are exported for the `$penv{...}` variables used by `CMakePresets.json`.
8. `cmake --preset <name>` configures with the generator selected by the
   preset (Ninja Multi-Config for desktop and simulator builds, Xcode for the
   physical iOS build) and lets the vcpkg toolchain install the manifest
   dependencies.

The native desktop jobs then build their Release configuration, install the
result, run CPack, and upload the generated packages. The macOS job optionally
signs the installed app before CPack and optionally notarizes/staples the DMG;
when its secrets are empty it remains an unsigned build. The iOS simulator job
uses the same macOS host setup but builds with Ninja Multi-Config, installs the
unsigned arm64 simulator app bundle, and uploads it as a ZIP. The Android job instead
builds the `apk` and `aab` targets, signs them, and uploads the signed files.
The physical iOS job configures the Xcode generator, creates an unsigned
`.xcarchive` when signing secrets are absent, and exports an IPA when the
certificate and provisioning-profile secrets are present. The WebAssembly job builds the Release configuration, installs the website
bundle, and uploads it directly; it does not run CPack.

Every platform job in this workflow uses a triplet with static vcpkg library
linkage. iOS uses
repository overlay triplets that wrap the pinned vcpkg community triplets, and
WebAssembly uses repository triplets because the built-in vcpkg registry has no
Emscripten pthread triplet:

The linkage values below were verified against the exact pinned vcpkg
baseline `eb2d3a3279fd019cb7733072d86900d0ad2a1aef`, not inferred from
triplet names. For repository overlays, the verification follows the
`include()` chain into the pinned upstream triplet.

All selected upstream triplets explicitly set both
`VCPKG_LIBRARY_LINKAGE` and `VCPKG_CRT_LINKAGE`; these values are not being
inferred from the triplet names. The repository-owned iOS overlays inherit
both values from their pinned community triplets and only append the
`libb2` configuration option. The WebAssembly overlay explicitly repeats both
values in the repository file, matching the pinned upstream Emscripten
triplet.

| Architecture | Platform | Triplet | VCPKG_LIBRARY_LINKAGE | VCPKG_CRT_LINKAGE | Build type | Overlay triplet | Definition verified in |
| --- | --- | --- | --- | --- | --- | --- | --- |
| x64 | Windows | `x64-windows-static-release` | static | static | release-only | None; baseline triplet | pinned `community/x64-windows-static-release.cmake` |
| arm64 | Windows | `arm64-windows-static-release` | static | static | release-only | None; baseline triplet | pinned `community/arm64-windows-static-release.cmake` |
| arm64 | macOS | `arm64-osx-release` | static | dynamic | release-only | None; baseline triplet | pinned `community/arm64-osx-release.cmake` |
| arm64 | iOS device | `arm64-ios-release` | static | dynamic | release-only | [arm64-ios-release.cmake](../../tools/vcpkg-custom-triplets/arm64-ios-release.cmake), wrapping the pinned community triplet | overlay plus pinned `community/arm64-ios-release.cmake` |
| arm64 | iOS simulator | `arm64-ios-simulator-release` | static | dynamic | release-only | [arm64-ios-simulator-release.cmake](../../tools/vcpkg-custom-triplets/arm64-ios-simulator-release.cmake), wrapping the pinned community triplet | overlay plus pinned `community/arm64-ios-simulator-release.cmake` |
| x64 | Linux | `x64-linux-release` | static | dynamic | release-only | None; baseline triplet | pinned `community/x64-linux-release.cmake` |
| arm64 | Linux | `arm64-linux-release` | static | dynamic | release-only | None; baseline triplet | pinned arm64 Linux release triplet |
| arm64 | Android (Windows host) | `arm64-android-release` | static | dynamic | release-only | None; baseline triplet | pinned `community/arm64-android-release.cmake` |
| wasm32 | WebAssembly/Emscripten (Windows host) | `wasm32-emscripten-pthread-release` | static | dynamic | release-only | [wasm32-emscripten-pthread-release.cmake](../../tools/vcpkg-custom-triplets/wasm32-emscripten-pthread-release.cmake); debug counterpart: [wasm32-emscripten-pthread.cmake](../../tools/vcpkg-custom-triplets/wasm32-emscripten-pthread.cmake) | overlay plus pinned `community/wasm32-emscripten.cmake` |

The WebAssembly presets also set `VCPKG_OVERLAY_TRIPLETS` to
`tools/vcpkg-custom-triplets`. This overlay provides the custom
`wasm32-emscripten-pthread` triplet and its Release-only
`wasm32-emscripten-pthread-release` variant; the release preset inherits the
overlay path from the base WebAssembly preset and selects the latter target
triplet.

The iOS configure presets additionally set `VCPKG_OVERLAY_PORTS` to
`tools/vcpkg-custom-ports`. Because one vcpkg manifest install also builds the
host `arm64-osx-release` tools needed by Qt, the overlay port is conditional:
it supplies an empty compatibility package for the iOS target, but runs the
normal upstream libb2 build for the macOS host and other non-iOS targets. The
pinned Qt/vcpkg graph declares `libb2` for `qtbase` even though Qt does not
enable its `libb2` input on iOS. The upstream Autotools port cannot
cross-configure that unused library for the iOS SDK. This avoids using
`--allow-unsupported`, which would attempt to build the broken target anyway.

Static triplets link vcpkg libraries statically where supported, reducing
application-library deployment work. They do not create completely
self-contained executables: Linux still depends on host components such as
glibc, graphics drivers, and display services. The Linux jobs therefore
publish DEB/TGZ packages and do not require linuxdeploy.

This follows vcpkg's triplet model: `VCPKG_LIBRARY_LINKAGE` belongs in the
triplet definition, while `VCPKG_TARGET_TRIPLET` and `VCPKG_HOST_TRIPLET`
select the target and host configurations from CMake. See the official
[Triplets](https://learn.microsoft.com/en-us/vcpkg/concepts/triplets) and
[triplet variables](https://learn.microsoft.com/en-us/vcpkg/users/triplets#variables)
documentation.

`VCPKG_LIBRARY_LINKAGE` and `VCPKG_CRT_LINKAGE` are separate vcpkg settings.
Static library linkage means vcpkg ports are built as static libraries.
According to vcpkg's triplet-variable reference, `VCPKG_CRT_LINKAGE` specifies
the desired CRT linkage **for MSVC** and accepts `dynamic` or `static`.
Therefore, the vcredist consequence applies to the Windows/MSVC jobs: a
dynamic MSVC CRT build requires the matching Microsoft Visual C++ Redistributable
on the target machine, while these `*-windows-static-*` triplets use the static
MSVC CRT and do not require that package for the MSVC runtime.

Linux, Apple, Android, and Emscripten do not use the Windows MSVC CRT and do
not consume a Windows vcredist package. Their pinned vcpkg triplets retain the
platform convention `VCPKG_CRT_LINKAGE dynamic`, but that value does not create
a Windows-style redistributable dependency. It also does not make the vcpkg
libraries dynamic: all triplets in this table retain static
`VCPKG_LIBRARY_LINKAGE`.

In particular, keep this line in
[wasm32-emscripten-pthread.cmake](../../tools/vcpkg-custom-triplets/wasm32-emscripten-pthread.cmake):

```cmake
set(VCPKG_CRT_LINKAGE dynamic)
```

The pinned upstream `community/wasm32-emscripten.cmake` contains the same
setting. The repository overlay inherits that triplet behavior and adds
pthread flags; removing the line would only make the setting implicit, while
changing it to `static` would diverge from the pinned upstream Emscripten
triplet without a demonstrated need.

## CMake presets and triplets

The configure and build presets in [CMakePresets.json](../../CMakePresets.json)
are the source of truth for the target architecture, vcpkg triplet, and build
configuration. The file currently contains 18 visible configure presets, 8
hidden inheritance presets, and 27 build presets. `<mark>CI/CD</mark>` marks
the presets referenced by [release.yml](release.yml); the other presets are
available for local development.

### Configure presets

The 8 hidden presets are inheritance-only and are not complete build
configurations. The architecture and platform columns follow the same
architecture-first order as the vcpkg triplet names:

| Architecture | Platform | Preset | Role |
| --- | --- | --- | --- |
| - | - | `base` | Shared CMake/vcpkg settings |
| x64 | Windows | `host-x64-windows-target-x64-windows-base` | x64 Windows host settings |
| arm64 | Windows | `host-arm64-windows-target-arm64-windows-base` | arm64 Windows host settings |
| x64 | Linux | `host-x64-linux-target-x64-linux-base` | x64 Linux host settings |
| arm64 | Linux | `host-arm64-linux-target-arm64-linux-base` | arm64 Linux host settings |
| arm64 | macOS | `host-arm64-osx-target-arm64-osx-base` | arm64 macOS host settings |
| - | Android | `android-base` | Shared Android toolchain settings |
| x64 host / arm64 target | Android on Windows | `host-x64-windows-target-arm64-android-base` | x64 Windows host and arm64 Android target settings |

The 18 visible configure presets are:

| Architecture | Platform | Configure preset | Target triplet | Intended use |
| --- | --- | --- | --- | --- |
| x64 | Windows | `host-x64-windows-target-x64-windows-static` | `x64-windows-static` | Local Debug/Release |
| x64 | Windows | `host-x64-windows-target-x64-windows-static-release` | `x64-windows-static-release` | <mark>CI/CD</mark> Release |
| arm64 | Windows | `host-arm64-windows-target-arm64-windows-static` | `arm64-windows-static` | Local Debug/Release |
| arm64 | Windows | `host-arm64-windows-target-arm64-windows-static-release` | `arm64-windows-static-release` | <mark>CI/CD</mark> Release |
| x64 | Linux | `host-x64-linux-target-x64-linux` | `x64-linux` | Local Debug/Release |
| x64 | Linux | `host-x64-linux-target-x64-linux-release` | `x64-linux-release` | <mark>CI/CD</mark> Release |
| arm64 | Linux | `host-arm64-linux-target-arm64-linux` | `arm64-linux` | Local Debug/Release |
| arm64 | Linux | `host-arm64-linux-target-arm64-linux-release` | `arm64-linux-release` | <mark>CI/CD</mark> Release |
| arm64 | macOS | `host-arm64-osx-target-arm64-osx` | `arm64-osx` | Local Debug/Release |
| arm64 | macOS | `host-arm64-osx-target-arm64-osx-release` | `arm64-osx-release` | <mark>CI/CD</mark> Release |
| arm64 | iOS device | `host-arm64-osx-target-arm64-ios` | `arm64-ios` | Local Debug/Release |
| arm64 | iOS device | `host-arm64-osx-target-arm64-ios-release` | `arm64-ios-release` | <mark>CI/CD</mark> Release |
| arm64 | iOS simulator | `host-arm64-osx-target-arm64-ios-simulator` | `arm64-ios-simulator` | Local Debug/Release |
| arm64 | iOS simulator | `host-arm64-osx-target-arm64-ios-simulator-release` | `arm64-ios-simulator-release` | <mark>CI/CD</mark> Release |
| arm64 | Android (Windows host) | `host-x64-windows-target-arm64-android` | `arm64-android` | Local Debug/Release |
| arm64 | Android (Windows host) | `host-x64-windows-target-arm64-android-release` | `arm64-android-release` | <mark>CI/CD</mark> Release |
| wasm32 | WebAssembly/Emscripten (Windows host) | `host-x64-windows-target-wasm32-emscripten` | `wasm32-emscripten-pthread` | Local Debug/Release |
| wasm32 | WebAssembly/Emscripten (Windows host) | `host-x64-windows-target-wasm32-emscripten-release` | `wasm32-emscripten-pthread-release` | <mark>CI/CD</mark> Release |

### Build presets

Every visible configure preset has build coverage. The 27 build presets below
show every supported local configuration and every CI release build:

| Build preset | Configure preset | Configuration | Use |
| --- | --- | --- | --- |
| `host-x64-windows-target-x64-windows-static-release` | `host-x64-windows-target-x64-windows-static` | Release | Local |
| `host-x64-windows-target-x64-windows-static-debug` | `host-x64-windows-target-x64-windows-static` | Debug | Local |
| `host-x64-windows-target-x64-windows-static-release-build` | `host-x64-windows-target-x64-windows-static-release` | Release | <mark>CI/CD</mark> |
| `host-arm64-windows-target-arm64-windows-static-release` | `host-arm64-windows-target-arm64-windows-static` | Release | Local |
| `host-arm64-windows-target-arm64-windows-static-debug` | `host-arm64-windows-target-arm64-windows-static` | Debug | Local |
| `host-arm64-windows-target-arm64-windows-static-release-build` | `host-arm64-windows-target-arm64-windows-static-release` | Release | <mark>CI/CD</mark> |
| `host-x64-linux-target-x64-linux-release` | `host-x64-linux-target-x64-linux` | Release | Local |
| `host-x64-linux-target-x64-linux-debug` | `host-x64-linux-target-x64-linux` | Debug | Local |
| `host-x64-linux-target-x64-linux-release-build` | `host-x64-linux-target-x64-linux-release` | Release | <mark>CI/CD</mark> |
| `host-arm64-linux-target-arm64-linux-release` | `host-arm64-linux-target-arm64-linux` | Release | Local |
| `host-arm64-linux-target-arm64-linux-debug` | `host-arm64-linux-target-arm64-linux` | Debug | Local |
| `host-arm64-linux-target-arm64-linux-release-build` | `host-arm64-linux-target-arm64-linux-release` | Release | <mark>CI/CD</mark> |
| `host-arm64-osx-target-arm64-osx-release` | `host-arm64-osx-target-arm64-osx` | Release | Local |
| `host-arm64-osx-target-arm64-osx-debug` | `host-arm64-osx-target-arm64-osx` | Debug | Local |
| `host-arm64-osx-target-arm64-osx-release-build` | `host-arm64-osx-target-arm64-osx-release` | Release | <mark>CI/CD</mark> |
| `host-arm64-osx-target-arm64-ios-release` | `host-arm64-osx-target-arm64-ios` | Release | Local |
| `host-arm64-osx-target-arm64-ios-release-build` | `host-arm64-osx-target-arm64-ios-release` | Release | Local/available; the workflow archives with direct Xcode tooling |
| `host-arm64-osx-target-arm64-ios-debug` | `host-arm64-osx-target-arm64-ios` | Debug | Local |
| `host-arm64-osx-target-arm64-ios-simulator-release` | `host-arm64-osx-target-arm64-ios-simulator` | Release | Local |
| `host-arm64-osx-target-arm64-ios-simulator-release-build` | `host-arm64-osx-target-arm64-ios-simulator-release` | Release | <mark>CI/CD</mark> |
| `host-arm64-osx-target-arm64-ios-simulator-debug` | `host-arm64-osx-target-arm64-ios-simulator` | Debug | Local |
| `host-x64-windows-target-arm64-android-release` | `host-x64-windows-target-arm64-android` | Release | Local |
| `host-x64-windows-target-arm64-android-debug` | `host-x64-windows-target-arm64-android` | Debug | Local |
| `host-x64-windows-target-arm64-android-release-build` | `host-x64-windows-target-arm64-android-release` | Release | <mark>CI/CD</mark> |
| `host-x64-windows-target-wasm32-emscripten-release` | `host-x64-windows-target-wasm32-emscripten` | Release | Local |
| `host-x64-windows-target-wasm32-emscripten-debug` | `host-x64-windows-target-wasm32-emscripten` | Debug | Local |
| `host-x64-windows-target-wasm32-emscripten-release-build` | `host-x64-windows-target-wasm32-emscripten-release` | Release | <mark>CI/CD</mark> |

The unsuffixed configure presets use normal triplets and support local Debug
and Release builds through their paired build presets. The `-release`
configure presets use Release-only triplets and are paired with the
`*-release-build` presets used by CI. The only configure presets without build
presets are the 8 hidden inheritance presets listed above.

The repository-owned triplet files are:

- [arm64-ios-release.cmake](../../tools/vcpkg-custom-triplets/arm64-ios-release.cmake)
- [arm64-ios-simulator-release.cmake](../../tools/vcpkg-custom-triplets/arm64-ios-simulator-release.cmake)
- [wasm32-emscripten-pthread.cmake](../../tools/vcpkg-custom-triplets/wasm32-emscripten-pthread.cmake)
- [wasm32-emscripten-pthread-release.cmake](../../tools/vcpkg-custom-triplets/wasm32-emscripten-pthread-release.cmake)

The iOS files disable the unused `libb2` system feature while preserving the
host macOS tool build. The WebAssembly release file inherits the pthread
configuration and sets `VCPKG_BUILD_TYPE` to `release`; the base WebAssembly
file remains suitable for local Debug and Release builds.

## Android build and signing

The Android job installs:

- Temurin JDK 21
- Android platform API 35
- Android compile platform API 36
- Android build-tools 35.0.0
- Android NDK 27.3.13750724

The commands are:

```text
cmake --build --preset host-x64-windows-target-arm64-android-release-build --target apk --parallel
cmake --build --preset host-x64-windows-target-arm64-android-release-build --target aab --parallel
cmake --build <build-dir> --config Release --target android_align_and_sign
```

The first two commands produce the unsigned Qt Android outputs. The project custom target invokes `tools/scripts/python/android/align-and-sign/align-and-sign.py` in silent mode. That script runs `zipalign` before `apksigner` for the APK and uses `jarsigner` for the AAB.

Configure these repository secrets before pushing a release tag:

- `ANDROID_KEYSTORE_BASE64`: base64-encoded contents of `aa-android-release-sign-keystore.jks`
- `ANDROID_KEYSTORE_PASSWORD`: keystore/key password

The workflow decodes `ANDROID_KEYSTORE_BASE64` into the temporary runner path `.android-keystore/aa-android-release-sign-keystore.jks`. The script discovers the only keystore and only alias automatically. The signing output is uploaded from `android-build/signed`.

Do not commit the `.jks` file. The base64 value is only an encoding, not encryption, but GitHub encrypts repository secrets at rest and masks them from normal workflow logs. Restrict repository write access and rotate the signing key only through a deliberate Android key migration process. For higher assurance, store the keystore in an external secret manager and have the workflow retrieve it with GitHub OIDC instead of storing the file in GitHub Secrets.

Create the file secret locally from PowerShell without printing it:

```powershell
$base64 = [Convert]::ToBase64String(
	[IO.File]::ReadAllBytes('.android-keystore\aa-android-release-sign-keystore.jks')
)
Set-Clipboard $base64
```

In GitHub, open **Settings > Secrets and variables > Actions > New repository secret** and create:

1. `ANDROID_KEYSTORE_BASE64`: paste the clipboard contents.
2. `ANDROID_KEYSTORE_PASSWORD`: enter the JKS/key password.

Do not add quotes or line breaks to either secret. The base64 value is a string representation of the binary JKS; it is not a password. GitHub Actions secrets have a size limit, so if the encoded keystore is too large, use an external secret manager with OIDC instead.

## WebAssembly build

`emscripten-core/setup-emsdk@v16` installs exactly emsdk `4.0.7`. `EMSCRIPTEN_ROOT` is exported for the custom `wasm32-emscripten-pthread-release` vcpkg triplet, and `emcc --version` verifies the selected compiler before configuration.

The installed WebAssembly files are uploaded as one static website bundle. The `_headers` file is included by the existing install rule, and the generated HTML is renamed to `index.html`.

## Apple builds, signing, and notarization

The macOS release uses the `host-arm64-osx-target-arm64-osx-release` preset,
which inherits Ninja Multi-Config. The iOS simulator release uses the
`host-arm64-osx-target-arm64-ios-simulator-release` configure preset and
`host-arm64-osx-target-arm64-ios-simulator-release-build` build preset with the
`arm64-ios-simulator-release` triplet. It intentionally produces an unsigned
simulator `.app`; a developer can unzip it and install it with:

```text
xcrun simctl install booted DemoApp.app
```

The device presets `host-arm64-osx-target-arm64-ios` and
`host-arm64-osx-target-arm64-ios-release` remain Xcode-based. The unsuffixed
preset uses `arm64-ios`, while the release preset uses `arm64-ios-release`.
The release job creates an Xcode archive.
An `.xcarchive` is the structured signed-build output that Xcode uses as the
input to export an installable `.ipa`. The provisioning profile tells Apple
which app identifier, team, devices, and entitlements the app may use; the
certificate proves the signing identity. `xcodebuild -exportArchive` applies
those settings to produce the IPA.
The simulator `.app` cannot be installed on a physical iPhone; a device build
must use the `arm64-ios-release` triplet and the Xcode release preset.

#### Check signing identities and install a simulator app

```bash
security find-identity -v -p codesigning
xcrun simctl install booted DemoApp.app
```

- `find-identity`: searches Keychain for signing identities.
- `-v`: prints verbose output, including the identity hash and certificate name.
- `-p codesigning`: applies the code-signing policy, filtering out identities that cannot sign code.
- `xcrun`: selects Apple developer tools from the active Xcode installation.
- `simctl`: controls iOS Simulator devices.
- `install`: installs an application bundle into a simulator.
- `booted`: targets the simulator device that is currently running. Replace it with a specific device UDID when multiple simulators are running.

The current release workflow does not require Apple certificates. The jobs
already guard their signing paths. Add these repository secrets when Apple
credentials are available:

- `APPLE_MACOS_CERTIFICATE_P12_BASE64`: base64-encoded macOS signing `.p12`
- `APPLE_IOS_CERTIFICATE_P12_BASE64`: base64-encoded iOS signing `.p12`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_MACOS_SIGNING_IDENTITY`: usually a `Developer ID Application: ...` identity
- `APPLE_IOS_SIGNING_IDENTITY`: usually an Apple Development or Distribution identity
- `APPLE_DEVELOPMENT_TEAM`
- `APPLE_IOS_PROVISIONING_PROFILE_BASE64` (device iOS only)
- `APPLE_IOS_EXPORT_METHOD` (optional: `development`, `ad-hoc`, or `app-store`; defaults to `development`)
- `APPLE_NOTARY_KEY_ID`, `APPLE_NOTARY_ISSUER_ID`, and `APPLE_NOTARY_PRIVATE_KEY_BASE64`

The macOS job runs `cmake --install` once, signs that installed `.app`, and
passes the same install tree to CPack for the DMG/TGZ packages. It then
notarizes the generated DMG with `xcrun notarytool` and staples it when all
macOS signing and notarization secrets are present. Notarization is skipped
when either signing or notarization secrets are incomplete. The physical iOS
job imports the iOS certificate,
installs the profile, passes the team/signing settings to `xcodebuild archive`,
and runs `xcodebuild -exportArchive` when all iOS signing secrets are present.
The simulator job intentionally does not use these secrets: simulator apps do
not need provisioning or notarization.

### Preparing certificates and GitHub secrets

The workflow expects `.p12` files containing both the Apple certificate and
its private key. A certificate file by itself is not sufficient for CI
signing. Prepare the files on a trusted macOS machine that has the required
certificate and private key installed in Keychain Access.

#### Create the macOS `.p12`

For a notarized macOS application, create or obtain a **Developer ID
Application** certificate in the Apple Developer account. Do not use an iOS
certificate for the macOS job.

1. Open **Keychain Access** and select the `login` keychain.
2. Find the `Developer ID Application: ...` certificate with its private key
	nested below it.
3. Select both the certificate and private key, then choose **File > Export
	Items...**.
4. Select `Personal Information Exchange (.p12)` as the file format.
5. Save the file, for example as `macos-signing.p12`.
6. Set an export password. This becomes `APPLE_CERTIFICATE_PASSWORD`.

Verify the identity locally without printing private material:

```bash
security find-identity -v -p codesigning
```

The identity passed to `APPLE_MACOS_SIGNING_IDENTITY` must exactly match the
identity shown by this command, for example:

```text
Developer ID Application: Example Company (TEAMID1234)
```

#### Create the iOS `.p12`

For a physical iPhone build, create or obtain an **Apple Development** or
**Apple Distribution** certificate, depending on the export method. The
certificate must have its private key available in Keychain Access.

1. Open **Keychain Access** and select the `login` keychain.
2. Find the iOS certificate with its private key nested below it.
3. Select both items and choose **File > Export Items...**.
4. Select `Personal Information Exchange (.p12)`.
5. Save the file, for example as `ios-signing.p12`.
6. Use the same export password as the macOS `.p12`, because the current
	workflow reads both passwords from `APPLE_CERTIFICATE_PASSWORD`.

Set `APPLE_IOS_SIGNING_IDENTITY` to the exact certificate identity shown by:

```bash
security find-identity -v -p codesigning
```

If macOS and iOS certificates need different passwords, the workflow must be
changed to use separate secrets such as `APPLE_MACOS_CERTIFICATE_PASSWORD` and
`APPLE_IOS_CERTIFICATE_PASSWORD` before uploading them.

#### Encode the `.p12` files as base64

GitHub Actions secrets are text values, so encode each binary `.p12` file as a
single-line base64 value. On macOS or Linux:

```bash
base64 -i macos-signing.p12 | tr -d '\n' > macos-signing.p12.base64
base64 -i ios-signing.p12 | tr -d '\n' > ios-signing.p12.base64
```

- `base64 -i`: reads the specified input file; `-i` is the macOS input-file option.
- `|`: sends the base64 output to the next command instead of saving it directly.
- `tr -d '\n'`: removes newline characters so the GitHub secret stays one line.
- `>`: writes the final single-line value to the `.base64` file.

On PowerShell:

```powershell
$macosBase64 = [Convert]::ToBase64String(
	[IO.File]::ReadAllBytes('.\macos-signing.p12')
)
$iosBase64 = [Convert]::ToBase64String(
	[IO.File]::ReadAllBytes('.\ios-signing.p12')
)
Set-Clipboard $macosBase64
# Paste into APPLE_MACOS_CERTIFICATE_P12_BASE64, then run:
Set-Clipboard $iosBase64
# Paste into APPLE_IOS_CERTIFICATE_P12_BASE64.
```

Paste each clipboard value into its corresponding secret. Do not add quotes,
spaces, or line breaks.
Do not print the base64 values in CI logs or commit the `.p12` or `.base64`
files to the repository.

#### Upload the secrets

In GitHub, open **Settings > Secrets and variables > Actions > New repository
secret**. Add the following values:

| Secret | Value |
| --- | --- |
| `APPLE_MACOS_CERTIFICATE_P12_BASE64` | Base64 contents of `macos-signing.p12` |
| `APPLE_IOS_CERTIFICATE_P12_BASE64` | Base64 contents of `ios-signing.p12` |
| `APPLE_CERTIFICATE_PASSWORD` | Password used when exporting both `.p12` files |
| `APPLE_MACOS_SIGNING_IDENTITY` | Exact `Developer ID Application: ...` identity |
| `APPLE_IOS_SIGNING_IDENTITY` | Exact Apple Development/Distribution identity |
| `APPLE_DEVELOPMENT_TEAM` | Apple Developer Team ID, usually 10 characters |

The `.p12` secrets are decoded only on the temporary macOS runner and
imported into a temporary keychain. GitHub masks configured secret values, but
base64 is encoding rather than encryption, so restrict repository write access
and rotate the certificate if a secret is exposed.

The provisioning-profile and App Store Connect API-key setup is described in
the command sections below. The simulator job does not require any of these
credentials.

### Apple signing command reference

The workflow keeps signing optional. Empty or incomplete secret groups select
the unsigned path and do not fail the job. When a complete group is present,
the commands below are executed on a macOS runner.

#### Import a `.p12` certificate

```bash
printf '%s' "$APPLE_CERTIFICATE_P12_BASE64" | base64 --decode > "$certificate"
security create-keychain -p "" "$keychain"
security set-keychain-settings -lut 21600 "$keychain"
security unlock-keychain -p "" "$keychain"
security import "$certificate" -k "$keychain" \
	-P "$APPLE_CERTIFICATE_PASSWORD" -T /usr/bin/codesign
security list-keychains -d user -s "$keychain"
security default-keychain -s "$keychain"
```

- `printf '%s'`: writes the secret without adding a newline.
- `base64 --decode`: reconstructs the binary `.p12` file from the GitHub secret. `--decode` is the long form of `-d`.
- `>`: redirects the decoded bytes into the destination file.
- `security create-keychain -p ""`: creates a temporary keychain with an empty keychain password. The certificate password is separate and belongs to the `.p12` file.
- `-lut 21600`: keeps the temporary keychain unlocked for 21,600 seconds.
- `security unlock-keychain`: unlocks the keychain for signing tools.
- `security import`: imports the certificate and private key.
- `-k`: selects the destination keychain.
- `-P`: supplies the `.p12` import password.
- `-T /usr/bin/codesign`: allows `codesign` to use the imported key.
- `list-keychains` and `default-keychain`: make the temporary keychain visible to Apple tools.
- `-d user`: selects the current macOS user's keychain domain for `list-keychains`.
- `-s`: sets the supplied keychain list or default keychain.

The macOS and iOS jobs use separate certificate secrets because their
certificates normally have different purposes:

```text
APPLE_MACOS_CERTIFICATE_P12_BASE64 -> macOS Developer ID certificate
APPLE_IOS_CERTIFICATE_P12_BASE64   -> iOS Development or Distribution certificate
```

#### Sign and verify a macOS app

```bash
codesign --deep --force --verbose --options runtime --timestamp \
	--sign "$APPLE_MACOS_SIGNING_IDENTITY" "$app"
codesign --verify --deep --strict --verbose=2 "$app"
```

- `--deep`: signs nested code such as frameworks and helper executables.
- `--force`: replaces an existing signature.
- `--verbose`: prints signing details.
- `--options runtime`: enables the hardened runtime required for typical notarization.
- `--timestamp`: requests a trusted signing timestamp.
- `--sign`: selects the certificate identity.
- `--verify`: checks the resulting signature.
- `--strict`: performs strict bundle validation.
- `--verbose=2`: prints detailed verification diagnostics.

The app is signed before CPack creates the DMG. This ensures the packaged app
contains the signature that Apple notarization evaluates. Do not run a second
`cmake --install` after signing, because it could refresh the package input
with an unsigned copy.

#### Submit and staple macOS notarization

```bash
printf '%s' "$APPLE_NOTARY_PRIVATE_KEY_BASE64" | base64 --decode > "$key"
xcrun notarytool submit "$dmg" --key "$key" \
	--key-id "$APPLE_NOTARY_KEY_ID" \
	--issuer "$APPLE_NOTARY_ISSUER_ID" --wait
xcrun stapler staple "$dmg"
```

- `xcrun`: invokes the Apple developer tool selected by the installed Xcode.
- `notarytool submit`: uploads the DMG to Apple for notarization.
- `--key`: points to the App Store Connect API private key file.
- `--key-id`: identifies the App Store Connect API key.
- `--issuer`: identifies the App Store Connect API issuer.
- `--wait`: keeps the command running until Apple returns a final result.
- `stapler staple`: attaches the notarization ticket to the DMG for offline verification.

These three values are used together:

```text
APPLE_NOTARY_PRIVATE_KEY_BASE64 -> contents of the App Store Connect .p8 key
APPLE_NOTARY_KEY_ID              -> App Store Connect API key ID
APPLE_NOTARY_ISSUER_ID           -> App Store Connect issuer ID
```

#### Install an iOS provisioning profile

```bash
printf '%s' "$APPLE_IOS_PROVISIONING_PROFILE_BASE64" | base64 --decode > "$profile"
security cms -D -i "$profile" -o "$profile_plist"
profile_uuid="$(/usr/libexec/PlistBuddy -c 'Print :UUID' "$profile_plist")"
profile_name="$(/usr/libexec/PlistBuddy -c 'Print :Name' "$profile_plist")"
mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
cp "$profile" "$HOME/Library/MobileDevice/Provisioning Profiles/$profile_uuid.mobileprovision"
```

- `security cms -D`: decodes the signed provisioning-profile CMS container into XML.
- `-i`: selects the input profile.
- `-o`: writes the decoded profile property list.
- `PlistBuddy -c`: reads a named property from the profile.
- `UUID`: provides the filename Apple tooling expects.
- `Name`: provides the profile name passed to Xcode.
- `mkdir -p`: creates the standard profile directory if needed.

The profile must match the app bundle identifier, team, device/build purpose,
and entitlements. The workflow derives the bundle identifier from the first
part of the tag before the first hyphen. For example,
`DemoApp-v1.0.0.0-release` produces `com.github.xyzdelete.DemoApp`, so the
uploaded profile must be valid for that identifier.

#### Create an iOS archive

```bash
xcodebuild \
	-project "$build"/*.xcodeproj \
	-scheme DemoApp \
	-configuration Release \
	-sdk iphoneos \
	-destination "generic/platform=iOS" \
	-archivePath "$archive" \
	DEVELOPMENT_TEAM="$APPLE_DEVELOPMENT_TEAM" \
	CODE_SIGN_STYLE=Manual \
	CODE_SIGN_IDENTITY="$APPLE_IOS_SIGNING_IDENTITY" \
	PROVISIONING_PROFILE_SPECIFIER="$profile_name" \
	archive
```

- `-project`: selects the generated Xcode project. The workflow expands `"$build"/*.xcodeproj` and requires exactly one matching project.
- `-scheme`: selects the target and build settings to build. The workflow runs `xcodebuild -list -json`, reads the generated project's schemes, and requires exactly one scheme instead of hardcoding a name.
- `-configuration Release`: selects the Release configuration.
- `-sdk iphoneos`: targets physical iOS devices, not the simulator.
- `-destination "generic/platform=iOS"`: creates a device archive without requiring a connected iPhone.
- `-archivePath`: selects the `.xcarchive` output directory.
- `DEVELOPMENT_TEAM`: sets the Apple Developer Team ID.
- `CODE_SIGN_STYLE=Manual`: tells Xcode to use the supplied identity/profile.
- `CODE_SIGN_IDENTITY`: selects the imported signing certificate.
- `PROVISIONING_PROFILE_SPECIFIER`: selects the installed profile by name.
- `archive`: asks Xcode to create the archive.

When signing secrets are incomplete, the workflow instead adds:

```text
CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

This creates an unsigned archive for CI validation. It cannot be installed on
a physical iPhone until it is rebuilt or signed with a valid device profile.

#### Export an IPA

The archive is exported with an options property list:

```xml
<key>method</key>
<string>development</string>
<key>signingStyle</key>
<string>manual</string>
<key>teamID</key>
<string>YOUR_TEAM_ID</string>
<key>provisioningProfiles</key>
<dict>
	<key>com.github.xyzdelete.&lt;app-name-from-tag&gt;</key>
	<string>YOUR_PROFILE_NAME</string>
</dict>
```

The workflow runs:

```bash
xcodebuild -exportArchive \
	-archivePath "$archive" \
	-exportOptionsPlist "$export_options" \
	-exportPath "$build/release-artifacts"
```

- `-exportArchive`: converts an `.xcarchive` into an installable package.
- `-archivePath`: selects the archive to export.
- `-exportOptionsPlist`: selects the export method, signing style, team, and profile mapping.
- `-exportPath`: selects the directory receiving the IPA and related files.
- `method`: controls distribution type; the workflow defaults to `development` and supports `ad-hoc` and `app-store` through `APPLE_IOS_EXPORT_METHOD`.
- `signingStyle`: `manual` makes the export use the explicitly supplied profile and identity.
- `teamID`: identifies the Apple Developer team.
- `provisioningProfiles`: maps each bundle identifier to its provisioning-profile name.

The workflow finally renames `DemoApp.ipa` to the tag-specific release name.
The simulator job never runs this export path because simulator apps are not
distributed as device IPAs and do not require provisioning or notarization.

## Creating a release

Push a tag such as:

```powershell
git tag ProjectName-release-v1.0.0
git push origin ProjectName-release-v1.0.0
```

The release workflow is triggered by tags matching this GitHub Actions pattern:

```text
*-v*-release
```


The workflow creates nine platform artifacts, then the `publish-release` job
downloads them, flattens them into one directory, and publishes them to a
GitHub Release with generated release notes. There is no `workflow_dispatch`
trigger.

## Important limitations

- The workflow does not sign Windows binaries. macOS signing/notarization and iOS device IPA export remain conditional on repository secrets, certificates, provisioning profiles, and platform-specific identities.
