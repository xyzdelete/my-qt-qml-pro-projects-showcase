#pragma once

// AppleClang ships no C++20 module dependency scanner (clang-scan-deps), so
// CMake's FILE_SET CXX_MODULES cannot be scanned/built on Apple platforms
// (see CMAKE_CXX_SCAN_FOR_MODULES=OFF in the osx CMake presets). This header
// is the header-only equivalent of ModuleExample.cppm, used only on Apple in
// place of `import ModuleExample;`.
#if defined(__APPLE__)

namespace ModuleExample
{
void
hello_world();
} // namespace ModuleExample

#endif // defined(__APPLE__)
