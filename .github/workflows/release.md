# Release workflow

The release workflow is [release.yml](release.yml). It runs when a tag matching `*-v*-release` is pushed.

## Why the workflow uses native runners

GitHub-hosted Docker containers are available for Linux jobs, but they cannot provide a hosted macOS runner with Xcode or a hosted Windows runner with MSVC. The workflow therefore uses native runners:

| Job | Runner | Preset | Output |
|---|---|---|---|
| `host-x64-windows-target-x64-windows-static-release` | `windows-latest` | `host-x64-windows-target-x64-windows-static-release` | ZIP and NSIS `.exe` |
| `host-arm64-osx-target-arm64-osx-release` | `macos-latest` | `host-arm64-osx-target-arm64-osx-release` | DMG and TGZ |
| `host-x64-linux-target-x64-linux-release` | `ubuntu-26.04` | `host-x64-linux-target-x64-linux-release` | DEB, TGZ |
| `host-arm64-linux-target-arm64-linux-release` | `ubuntu-26.04-arm` | `host-arm64-linux-target-arm64-linux-release` | DEB, TGZ |
| `host-x64-windows-target-arm64-android-release` | `windows-latest` | `host-x64-windows-target-arm64-android-release` | aligned/signed APK and AAB |
| `host-x64-windows-target-wasm32-emscripten-release` | `windows-latest` | `host-x64-windows-target-wasm32-emscripten-release` | HTML, JavaScript, WASM and assets |

The Linux arm64 release job uses a native arm64 Ubuntu runner with the static `host-arm64-linux-target-arm64-linux-release` preset. It builds the arm64 binary natively and publishes DEB/TGZ packages. It does not invoke linuxdeploy because this workflow intentionally uses only static vcpkg triplets.

## Common setup commands

Each platform build job performs the common dependency setup below:

1. `actions/checkout@v7` checks out the tag commit.
2. `lukka/get-cmake@latest` supplies a current CMake release. The project requires CMake 4.4.1 or newer.
3. The macOS job installs Homebrew `autoconf`, `autoconf-archive`, `automake`, and `libtool`, while both Linux jobs install the equivalent Debian packages. These tools are required by vcpkg ports such as `gperf` and `libb2`.
4. `git clone https://github.com/microsoft/vcpkg.git` downloads vcpkg.
5. `git checkout 04a9d8e5212d01ee1dd9478eadd9caade4f8b0d4` selects the baseline pinned in `vcpkg-configuration.json` and the workflow environment.
6. `bootstrap-vcpkg` builds the vcpkg executable without telemetry.
7. `BUILD_ROOT`, `VCPKG_ROOT`, `VCPKG_INSTALLED_ROOT`, and `VCPKG_BUILDTREES_ROOT` are exported for the `$penv{...}` variables used by `CMakePresets.json`.
8. `cmake --preset <name>` configures with Ninja Multi-Config and lets the vcpkg toolchain install the manifest dependencies.

The native desktop jobs then build their Release configuration, install the
result, run CPack, and upload the generated packages. The Android job instead
builds the `apk` and `aab` targets, signs them, and uploads the signed files.
The WebAssembly job builds the Release configuration, installs the website
bundle, and uploads it directly; it does not run CPack.

Every platform job in this workflow uses a static vcpkg triplet. WebAssembly
is the only target that needs an overlay triplet, since the built-in vcpkg
registry has no Emscripten pthread triplet:

| Platform job | Static vcpkg triplet | Overlay triplet |
| --- | --- | --- |
| Windows x64 | `x64-windows-static-release` | - (built-in) |
| macOS arm64 | `arm64-osx-release` | - (built-in) |
| Linux x64 | `x64-linux-release` | - (built-in) |
| Linux arm64 | `arm64-linux-release` | - (built-in) |
| Android arm64 | `arm64-android-release` | - (built-in) |
| WebAssembly | `wasm32-emscripten-pthread-release` | [wasm32-emscripten-pthread-release.cmake](../../tools/vcpkg-custom-triplets/wasm32-emscripten-pthread-release.cmake) (debug counterpart: [wasm32-emscripten-pthread.cmake](../../tools/vcpkg-custom-triplets/wasm32-emscripten-pthread.cmake)) |

The WebAssembly presets also set `VCPKG_OVERLAY_TRIPLETS` to
`tools/vcpkg-custom-triplets`. This overlay provides the custom
`wasm32-emscripten-pthread` triplet and its Release-only
`wasm32-emscripten-pthread-release` variant; the release preset inherits the
overlay path from the base WebAssembly preset and selects the latter target
triplet.

Static triplets link vcpkg libraries statically where supported, reducing
application-library deployment work. They do not create completely
self-contained executables: Linux still depends on host components such as
glibc, graphics drivers, and display services. The Linux jobs therefore
publish DEB/TGZ packages and do not require linuxdeploy.

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

## Creating a release

Push a tag such as:

```powershell
git tag Qt6QmlForBeginners-release-v1.0.0
git push origin Qt6QmlForBeginners-release-v1.0.0
```

The release workflow is triggered by tags matching this GitHub Actions pattern:

```text
*-v*-release
```


The workflow creates six platform artifacts, then the `publish-release` job
downloads them, flattens them into one directory, and publishes them to a
GitHub Release with generated release notes. There is no `workflow_dispatch`
trigger.

## Important limitations

- The workflow does not sign Windows or macOS binaries. Code signing and notarization require repository secrets, certificates, and platform-specific identity setup.
