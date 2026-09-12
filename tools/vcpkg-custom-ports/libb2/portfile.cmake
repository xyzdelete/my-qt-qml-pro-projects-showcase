if(VCPKG_TARGET_IS_IOS)
    message(STATUS "libb2 is not consumed by Qt on iOS; providing an empty compatibility package")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    file(
        WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright"
        "This is an iOS compatibility overlay for libb2 in this repository.\n"
    )
    return()
endif()

include("${VCPKG_ROOT_DIR}/ports/libb2/portfile.cmake")
