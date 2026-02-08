set(VCPKG_ENV_PASSTHROUGH_UNTRACKED EMSCRIPTEN_ROOT EMSDK PATH)

if(NOT DEFINED ENV{EMSCRIPTEN_ROOT})
   find_path(EMSCRIPTEN_ROOT "emcc")
else()
   set(EMSCRIPTEN_ROOT "$ENV{EMSCRIPTEN_ROOT}")
endif()

if(NOT EMSCRIPTEN_ROOT)
   if(NOT DEFINED ENV{EMSDK})
      message(FATAL_ERROR "The emcc compiler not found in PATH")
   endif()
   set(EMSCRIPTEN_ROOT "$ENV{EMSDK}/upstream/emscripten")
endif()

if(NOT EXISTS "${EMSCRIPTEN_ROOT}/cmake/Modules/Platform/Emscripten.cmake")
   message(FATAL_ERROR "Emscripten.cmake toolchain file not found")
endif()

set(VCPKG_TARGET_ARCHITECTURE wasm32)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Emscripten)
set(VCPKG_C_FLAGS "-pthread")
set(VCPKG_CXX_FLAGS "-pthread")
set(VCPKG_LINKER_FLAGS "-pthread")
# Chainload vcpkg's wrapper toolchain rather than Emscripten.cmake directly:
# the wrapper includes Emscripten.cmake and then applies VCPKG_C(XX)_FLAGS
# and VCPKG_LINKER_FLAGS, which would otherwise be silently dropped.
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${VCPKG_ROOT_DIR}/scripts/toolchains/emscripten.cmake")

# Some qtdeclarative TUs (e.g. QuickControlsTestUtilsPrivate) generate compile
# commands with huge -I lists that exceed Windows' ~8191-char cmd.exe limit,
# failing with "The command line is too long." Force Ninja to always emit
# response files for compile/link commands to work around this.
list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_NINJA_FORCE_RESPONSE_FILE=ON")
