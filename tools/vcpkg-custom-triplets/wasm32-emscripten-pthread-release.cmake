include("${CMAKE_CURRENT_LIST_DIR}/wasm32-emscripten-pthread.cmake")

# CI-only variant: build Release-only vcpkg ports (base triplet stays debug+release for local use)
set(VCPKG_BUILD_TYPE release)
