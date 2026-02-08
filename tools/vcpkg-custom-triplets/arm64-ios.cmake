include("${VCPKG_ROOT_DIR}/triplets/community/arm64-ios.cmake")

list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DFEATURE_system_libb2=OFF")