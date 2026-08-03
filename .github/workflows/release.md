# Release workflow

The release workflow is [release.yml](release.yml). It runs for tags matching `tag-*-release-v*`, or manually through **Actions > Release > Run workflow**.

## Why the workflow uses native runners

GitHub-hosted Docker containers are available for Linux jobs, but they cannot provide a hosted macOS runner with Xcode or a hosted Windows runner with MSVC. The workflow therefore uses native runners:

| Job | Runner | Preset | Output |
|---|---|---|---|
| `host-x64-windows-target-x64-windows-static` | `windows-latest` | `host-x64-windows-target-x64-windows-static` | ZIP and NSIS `.exe` |
| `host-arm64-osx-target-arm64-osx` | `macos-latest` | `host-arm64-osx-target-arm64-osx` | DMG and TGZ |
| `host-x64-linux-target-x64-linux` | `ubuntu-latest` | `host-x64-linux-target-x64-linux` | DEB, TGZ |
| `host-arm64-linux-target-arm64-linux` | `ubuntu-latest` | `host-arm64-linux-target-arm64-linux` | DEB, TGZ |
| `host-x64-windows-target-arm64-android` | `windows-latest` | `host-x64-windows-target-arm64-android` | aligned/signed APK and AAB |
| `host-x64-windows-target-wasm32-emscripten` | `windows-latest` | `host-x64-windows-target-wasm32-emscripten` | HTML, JavaScript, WASM and assets |

The Linux arm64 release job uses `ubuntu-latest` with `aarch64-linux-gnu-g++` and the static `host-arm64-linux-target-arm64-linux` preset. It cross-compiles the arm64 binary and publishes DEB/TGZ packages. It does not invoke linuxdeploy because this workflow intentionally uses only static vcpkg triplets. The dynamic preset remains available for a future native arm64 AppImage job.

## Common setup commands

Each job performs the same dependency setup:

1. `actions/checkout@v4` checks out the tag commit.
2. `lukka/get-cmake@latest` supplies a current CMake release. The project requires CMake 4.4.1 or newer.
3. The macOS job installs Homebrew `autoconf`, `autoconf-archive`, `automake`, and `libtool`, while both Linux jobs install the equivalent Debian packages. These tools are required by vcpkg ports such as `gperf` and `libb2`.
4. `git clone https://github.com/microsoft/vcpkg.git` downloads vcpkg.
5. `git checkout ea1a7396b05637a53bf23c078647ecc0edee4b80` selects the baseline pinned in `vcpkg-configuration.json`.
6. `bootstrap-vcpkg` builds the vcpkg executable without telemetry.
7. `BUILD_ROOT`, `VCPKG_ROOT`, `VCPKG_INSTALLED_ROOT`, and `VCPKG_BUILDTREES_ROOT` are exported for the `$penv{...}` variables used by `CMakePresets.json`.
8. `cmake --preset <name>` configures with Ninja Multi-Config and lets the vcpkg toolchain install the manifest dependencies.
9. `cmake --build --preset <name>-release` builds the Release configuration.
10. `cmake --install <build-dir> --config Release` copies the installable files into the preset install directory.
11. `cpack --config Release --working-directory <build-dir>` creates the configured archive, installer, or package.
12. `actions/upload-artifact@v4` uploads the generated files to the workflow run.

The workflow uses static vcpkg triplets for every platform. This reduces application-library deployment work, but it does not create one completely self-contained executable: Linux still depends on host system components such as glibc, graphics drivers, and display services. The Linux static jobs therefore publish DEB/TGZ packages and do not require linuxdeploy.

## Linux AppImage behavior

The current static release workflow does not build AppImages. The CMake `AppImage` target exists only in the dynamic Linux branch. If AppImage output is needed later, use a native arm64 runner for arm64 and a dynamic preset, then the target downloads `linuxdeploy` and its Qt plugin and runs it with:

```text
--appimage-extract-and-run
```

That option extracts the linuxdeploy AppImage before executing it, so the runner does not need FUSE. It is the correct linuxdeploy option for a CI environment where mounting AppImages is unavailable. `--extract-appimage` is not the linuxdeploy runtime option.

The workflow also creates the existing CPack DEB and TGZ outputs. Because the arm64 job is native, normal Debian shared-library dependency scanning can run there too.

## Android build and signing

The Android job installs:

- Temurin JDK 21
- Android platform API 35
- Android compile platform API 36
- Android build-tools 35.0.0
- Android NDK 27.2.12479018

The commands are:

```text
cmake --build --preset host-x64-windows-target-arm64-android-release --target apk
cmake --build --preset host-x64-windows-target-arm64-android-release --target aab
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

`mymindstorm/setup-emsdk@v14` installs exactly emsdk `4.0.7`. The preset now uses `$env{EMSDK}` instead of a machine-specific `C:/emsdk` path. `EMSCRIPTEN_ROOT` is exported for the custom `wasm32-emscripten-pthread` vcpkg triplet, and `emcc --version` verifies the selected compiler before configuration.

The installed WebAssembly files are uploaded as one static website bundle. The `_headers` file is included by the existing install rule, and the generated HTML is renamed to `index.html`.

## Creating a release

Push a tag such as:

```powershell
git tag tag-Qt6QmlForBeginners-release-v1.0.0
git push origin tag-Qt6QmlForBeginners-release-v1.0.0
```

The workflow produces separate downloadable artifacts for each platform. It does not publish a GitHub Release automatically; the artifacts remain attached to the Actions run so the release can be inspected before publication.

## Important limitations

- The workflow does not sign Windows or macOS binaries. Code signing and notarization require repository secrets, certificates, and platform-specific identity setup.
- `CPACK_NSIS_EXTRA_INSTALL_COMMANDS` references `vc_redist.x64.exe`, but the Windows release uses the static triplet and therefore does not need that runtime installer. If a dynamic Windows preset is selected later, that installer must be supplied and its architecture must match the target.
- Linux AppImage downloads currently use the upstream `continuous` linuxdeploy builds. For long-term reproducibility, pin the linuxdeploy and Qt plugin release URLs after selecting a known-good version.
- The workflow intentionally does not claim that Docker can replace native Windows/MSVC or macOS/Xcode runners. A self-hosted runner can provide those toolchains if containerized builds are a hard requirement.