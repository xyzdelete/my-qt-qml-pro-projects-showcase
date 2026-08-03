cmake_minimum_required(
  VERSION 4.4.1
)

project(
  RESTClientApp
  VERSION 1.0.0.0
  LANGUAGES CXX
)

set(
  PROJECT_AUTHOR
  "xyzdelete"
)
set(
  PROJECT_VENDOR
  "com.github.${PROJECT_AUTHOR}"
)
set(
  PROJECT_ID
  "${PROJECT_VENDOR}.${PROJECT_NAME}"
)

message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}"
)

qt_add_executable(
  ${PROJECT_NAME}
)

file(
  GLOB
  CPP_HEADERS
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/cpp/headers/*.hpp
)
message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "CPP_HEADERS: ${CPP_HEADERS}"
)

file(
  GLOB
  CPP_FILES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/cpp/files/*.cpp
)
message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "CPP_FILES: ${CPP_FILES}"
)

file(
  GLOB
  CPP_MODULES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/cpp/modules/*.cppm
)
message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "CPP_MODULES: ${CPP_MODULES}"
)

file(
  GLOB
  QML_FILES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qml/files/*.qml
)
message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "QML_FILES: ${QML_FILES}"
)

file(
  GLOB_RECURSE
  RESOURCES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/resources/*
)
message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "RESOURCES: ${RESOURCES}"
)

qt_add_qml_module(
  ${PROJECT_NAME}
  URI
  ${PROJECT_NAME}
  QML_FILES
  ${QML_FILES}
  # IMPORTS TARGET
  SOURCES
  ${CPP_HEADERS}
  ${CPP_FILES}
  RESOURCES
  ${RESOURCES}
)

if(
  CPP_MODULES
)
  target_sources(
    ${PROJECT_NAME}
    PUBLIC FILE_SET
           CXX_MODULES
           FILES
           ${CPP_MODULES}
  )
endif()

target_include_directories(
  ${PROJECT_NAME}
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/sources/cpp/headers
)

if(
  NOT
  ANDROID
)
  target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE Qt6::Quick
            Qt6::QuickControls2
            Qt6::Network
            Qt6::Test
            Qt6::QuickTest
            Qt6::Widgets
            StaticLibModuleExample
  )
elseif(
  ANDROID
)
  target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE Qt6::Quick
            Qt6::QuickControls2
            Qt6::Network
            Qt6::Widgets
            StaticLibModuleExample
  )
endif()

target_compile_options(
  ${PROJECT_NAME}
  PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/utf-8>
          # /wd5050: MSVC's pre-compiled std module lacks /utf-8, causing a
          # false C5050
          $<$<CXX_COMPILER_ID:MSVC>:/wd5050>
          $<$<CXX_COMPILER_ID:MSVC>:/W3>
          $<$<CXX_COMPILER_ID:MSVC>:/WX>
          $<$<CXX_COMPILER_ID:MSVC>:/permissive->
          $<$<CXX_COMPILER_ID:MSVC>:/translateInclude>
          $<$<CXX_COMPILER_ID:MSVC>:/bigobj>
)

include(
  GNUInstallDirs
)

install(
  TARGETS ${PROJECT_NAME}
  BUNDLE DESTINATION .
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX} "
         "CMAKE_INSTALL_LIBDIR: ${CMAKE_INSTALL_LIBDIR} "
         "CMAKE_INSTALL_BINDIR: ${CMAKE_INSTALL_BINDIR}"
)

# ============================================================================
# Cross-Platform Icon Configuration
# ============================================================================

set(
  PROJECT_ICON_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/sources/resources/assets/icons/bundle/light/squared"
)

# Bundle / executable type flags are harmless on every platform. Qt for iOS sets
# MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1; uncomment the line
# below to pin an explicit identifier.
set_target_properties(
  ${PROJECT_NAME}
  PROPERTIES
    MACOSX_BUNDLE
    TRUE
    MACOSX_BUNDLE_ICON_FILE
    ${PROJECT_NAME}.icns
    MACOSX_BUNDLE_BUNDLE_NAME
    ${PROJECT_NAME}
    MACOSX_BUNDLE_GUI_IDENTIFIER
    ${PROJECT_ID}
    MACOSX_BUNDLE_BUNDLE_VERSION
    ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING
    ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}
    WIN32_EXECUTABLE
    TRUE
)

# ==============================================================================
# ICONS BLOCK
# ==============================================================================
# Add Windows RC file with icon
if(
  WIN32
)
  set(
    PROJECT_ICON_FILE
    "${PROJECT_ICON_DIR}/windows/${PROJECT_NAME}.rc"
  )
  message(
    STATUS "PROJECT_NAME: ${PROJECT_NAME} "
           "PROJECT_ICON_FILE: ${PROJECT_ICON_FILE}"
  )
  target_sources(
    ${PROJECT_NAME}
    PRIVATE ${PROJECT_ICON_FILE}
  )
elseif(
  APPLE
  AND NOT
      IOS
)
  set(
    PROJECT_ICON_FILE
    "${PROJECT_ICON_DIR}/macos/${PROJECT_NAME}.icns"
  )
  message(
    STATUS "PROJECT_NAME: ${PROJECT_NAME} "
           "PROJECT_ICON_FILE: ${PROJECT_ICON_FILE}"
  )
  set_source_files_properties(
    "${PROJECT_ICON_FILE}"
    PROPERTIES MACOSX_PACKAGE_LOCATION
               Resources
  )
  target_sources(
    ${PROJECT_NAME}
    PRIVATE "${PROJECT_ICON_FILE}"
  )
elseif(
  IOS
)
  target_sources(
    ${PROJECT_NAME}
    PRIVATE ${PROJECT_ICON_DIR}/ios/Assets.xcassets
  )
  set_source_files_properties(
    Assets.xcassets
    PROPERTIES MACOSX_PACKAGE_LOCATION
               "Resources"
  )

  set_target_properties(
    ${PROJECT_NAME}
    PROPERTIES
      MACOSX_BUNDLE
      TRUE
      MACOSX_BUNDLE_BUNDLE_NAME
      ${PROJECT_NAME}
      MACOSX_BUNDLE_GUI_IDENTIFIER
      ${PROJECT_ID}
      MACOSX_BUNDLE_BUNDLE_VERSION
      ${PROJECT_VERSION}
      MACOSX_BUNDLE_SHORT_VERSION_STRING
      ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}
      XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY
      "1,2"
      XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET
      ${CMAKE_OSX_DEPLOYMENT_TARGET}
      XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME
      "AppIcon"
      XCODE_ATTRIBUTE_INFOPLIST_KEY_UILaunchScreen_Generation
      YES
  )
elseif(
  ANDROID
)
  message(
    STATUS "PROJECT_NAME: ${PROJECT_NAME} "
           "ANDROID_MIN_SDK_VERSION: ${ANDROID_MIN_SDK_VERSION}"
  )
  message(
    STATUS "PROJECT_NAME: ${PROJECT_NAME} "
           "ANDROID_TARGET_SDK_VERSION: ${ANDROID_TARGET_SDK_VERSION}"
  )
  message(
    STATUS "PROJECT_NAME: ${PROJECT_NAME} "
           "ANDROID_COMPILE_SDK_VERSION: ${ANDROID_COMPILE_SDK_VERSION}"
  )

  math(
    EXPR
    ANDROID_VERSION_CODE
    "${PROJECT_VERSION_MAJOR} * 10000 + ${PROJECT_VERSION_MINOR} * 100 + ${PROJECT_VERSION_PATCH}"
  )

  message(
    STATUS "PROJECT_NAME: ${PROJECT_NAME} "
           "Version code: ${ANDROID_VERSION_CODE}"
  )

  if(
    NOT
    Qt6_FOUND
  )
    message(
      FATAL_ERROR
        "${PROJECT_NAME}: Install Qt or add qtbase and qtdeclarative dependencies in vcpkg.json"
    )
  endif()

  set_target_properties(
    ${PROJECT_NAME}
    PROPERTIES
      QT_ANDROID_PACKAGE_SOURCE_DIR
      "${PROJECT_ICON_DIR}/android"
      QT_ANDROID_APP_ICON
      "@mipmap/ic_launcher"
      QT_ANDROID_PACKAGE_NAME
      "${PROJECT_ID}"
      QT_ANDROID_APP_NAME
      "${PROJECT_NAME}"
      QT_ANDROID_MIN_SDK_VERSION
      ${ANDROID_MIN_SDK_VERSION}
      QT_ANDROID_TARGET_SDK_VERSION
      ${ANDROID_TARGET_SDK_VERSION}
      QT_ANDROID_COMPILE_SDK_VERSION
      ${ANDROID_COMPILE_SDK_VERSION}
      QT_ANDROID_VERSION_NAME
      "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}"
      QT_ANDROID_VERSION_CODE
      "${ANDROID_VERSION_CODE}"
  )

  # Manually-launched target that zip-aligns and signs the release apk/aab
  # produced by this build (see tools/scripts/python/android/align-and-sign).
  # The password is read from an environment variable at invocation time:
  # $env:ANDROID_KEYSTORE_PASSWORD = "..."; cmake --build . --target
  # android_align_and_sign
  find_package(
    Python3
    COMPONENTS Interpreter
  )
  if(
    Python3_FOUND
  )
    add_custom_target(
      android_align_and_sign
      COMMAND
        ${Python3_EXECUTABLE}
        ${CMAKE_SOURCE_DIR}/tools/scripts/python/android/align-and-sign/align-and-sign.py
        --silent --repo-root ${CMAKE_SOURCE_DIR} --build-dir
        ${CMAKE_CURRENT_BINARY_DIR} --password-env ANDROID_KEYSTORE_PASSWORD
      COMMENT "Zip-aligning and signing the Android apk/aab"
      USES_TERMINAL
      VERBATIM
    )
  endif()
elseif(
  UNIX
  AND NOT
      APPLE
  AND NOT
      ANDROID
  AND NOT
      EMSCRIPTEN
)
  set(
    APP_DESKTOP_FILE
    "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${PROJECT_ID}.desktop"
  )

  set(
    ICON_SIZES
    16x16
    22x22
    24x24
    32x32
    48x48
    64x64
    96x96
    128x128
    256x256
    512x512
  )

  foreach(
    size
    IN
    LISTS ICON_SIZES
  )

    install(
      FILES "${PROJECT_ICON_DIR}/linux/${size}/apps/${PROJECT_NAME}.png"
      DESTINATION "share/icons/hicolor/${size}/apps"
      RENAME "${PROJECT_ID}.png"
    )

  endforeach()

  install(
    FILES "${PROJECT_ICON_DIR}/linux/scalable/apps/${PROJECT_NAME}.svg"
    DESTINATION "share/icons/hicolor/scalable/apps"
    RENAME "${PROJECT_ID}.svg"
  )

  file(
    WRITE
    "${APP_DESKTOP_FILE}"
    "[Desktop Entry]\n"
    "Type=Application\n"
    "Name=${PROJECT_NAME}\n"
    "Comment=${PROJECT_NAME}\n"
    "Exec=${PROJECT_NAME}\n"
    "Icon=${PROJECT_ID}\n"
    "Terminal=false\n"
    "Categories=Utility;\n"
    "StartupNotify=true\n"
  )

  install(
    FILES "${APP_DESKTOP_FILE}"
    DESTINATION "share/applications"
  )
endif()

if(
  USE_VCPKG
)
  message(
    STATUS "PROJECT_NAME: ${PROJECT_NAME} "
           "VCPKG_INSTALLED_DIR: ${VCPKG_INSTALLED_DIR} "
           "VCPKG_TARGET_TRIPLET: ${VCPKG_TARGET_TRIPLET} "
           "VCPKG_STATIC_LINKAGE: ${VCPKG_STATIC_LINKAGE}"
  )
  if(
    NOT
    VCPKG_STATIC_LINKAGE
  )
    if(
      WIN32
    )
      if(
        Qt6_FOUND
      )
        find_program(
          WINDEPLOYQT_EXECUTABLE
          NAMES windeployqt
                windeployqt.exe
          HINTS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/Qt6/bin"
          NO_DEFAULT_PATH
        )
        find_program(
          WINDEPLOYQT_DEBUG_EXECUTABLE
          NAMES windeployqt.debug.bat
          HINTS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/Qt6/bin"
          NO_DEFAULT_PATH
        )
        if(
          NOT
          WINDEPLOYQT_EXECUTABLE
          OR NOT
             WINDEPLOYQT_DEBUG_EXECUTABLE
        )
          message(
            FATAL_ERROR
              "${PROJECT_NAME}: windeployqt not found, enable qtbase's 'windeployqt' feature in vcpkg.json"
          )
        endif()

        add_custom_command(
          TARGET ${PROJECT_NAME}
          POST_BUILD
          COMMAND
            $<IF:$<CONFIG:Debug>,${WINDEPLOYQT_DEBUG_EXECUTABLE},${WINDEPLOYQT_EXECUTABLE}>
            $<TARGET_FILE:${PROJECT_NAME}> --qmldir
            ${CMAKE_CURRENT_SOURCE_DIR}/sources/qt/qml --qml-deploy-dir
            $<TARGET_FILE_DIR:${PROJECT_NAME}>/Qt6/qml $<$<CONFIG:Debug>:--pdb>
          COMMAND_EXPAND_LISTS
          COMMENT "Deploying Qt runtime next to ${PROJECT_NAME}"
          VERBATIM
        )
      endif()

      install(
        FILES "$<TARGET_PDB_FILE:${PROJECT_NAME}>"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS Debug
      )

      install(
        FILES $<TARGET_RUNTIME_DLLS:${PROJECT_NAME}>
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS Debug
                       Release
      )

      install(
        DIRECTORY "$<TARGET_FILE_DIR:${PROJECT_NAME}>/"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS Debug
        PATTERN "*.ilk"
                EXCLUDE
        PATTERN "*.exp"
                EXCLUDE
        PATTERN "*.lib"
                EXCLUDE
      )

      install(
        DIRECTORY "$<TARGET_FILE_DIR:${PROJECT_NAME}>/"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS Release
        PATTERN "*.pdb"
                EXCLUDE
        PATTERN "*.ilk"
                EXCLUDE
        PATTERN "*.exp"
                EXCLUDE
        PATTERN "*.lib"
                EXCLUDE
      )
    elseif(
      UNIX
      AND NOT
          APPLE
      AND NOT
          ANDROID
      AND NOT
          EMSCRIPTEN
    )
      if(
        CMAKE_SYSTEM_PROCESSOR
        MATCHES
        "x86_64|AMD64"
      )
        set(
          APPIMAGE_ARCH
          "x86_64"
        )
      elseif(
        CMAKE_SYSTEM_PROCESSOR
        MATCHES
        "aarch64|ARM64"
      )
        set(
          APPIMAGE_ARCH
          "aarch64"
        )
      else()
        message(
          FATAL_ERROR
            "${PROJECT_NAME}: Unsupported architecture ${CMAKE_SYSTEM_PROCESSOR}"
        )
      endif()

      set(
        LINUXDEPLOY_URL
        "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-${APPIMAGE_ARCH}.AppImage"
      )
      set(
        LINUXDEPLOY_QT_URL
        "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-${APPIMAGE_ARCH}.AppImage"
      )
      set(
        LINUXDEPLOY_DIR
        "${CMAKE_SOURCE_DIR}/tools/linux/linuxdeploy/${APPIMAGE_ARCH}"
      )
      set(
        LINUXDEPLOY_EXECUTABLE
        "${LINUXDEPLOY_DIR}/linuxdeploy-${APPIMAGE_ARCH}.AppImage"
      )
      set(
        LINUXDEPLOY_QT_PLUGIN
        "${LINUXDEPLOY_DIR}/linuxdeploy-plugin-qt-${APPIMAGE_ARCH}.AppImage"
      )

      add_custom_command(
        OUTPUT "${LINUXDEPLOY_EXECUTABLE}"
        COMMAND
          ${CMAKE_COMMAND} -E make_directory "${LINUXDEPLOY_DIR}"
        COMMAND
          curl -L -o "${LINUXDEPLOY_EXECUTABLE}" "${LINUXDEPLOY_URL}"
        COMMAND
          chmod +x "${LINUXDEPLOY_EXECUTABLE}"
        COMMENT "Fetching linuxdeploy (${APPIMAGE_ARCH})"
      )
      add_custom_target(
        DownloadLinuxDeploy
        DEPENDS "${LINUXDEPLOY_EXECUTABLE}"
      )

      set(
        LINUXDEPLOY_QT_PLUGIN_ARGS
        ""
      )
      set(
        APPIMAGE_QT_DEPENDS
        ""
      )

      if(
        Qt6_FOUND
      )
        add_custom_command(
          OUTPUT "${LINUXDEPLOY_QT_PLUGIN}"
          COMMAND
            ${CMAKE_COMMAND} -E make_directory "${LINUXDEPLOY_DIR}"
          COMMAND
            curl -L -o "${LINUXDEPLOY_QT_PLUGIN}" "${LINUXDEPLOY_QT_URL}"
          COMMAND
            chmod +x "${LINUXDEPLOY_QT_PLUGIN}"
          COMMENT "Fetching linuxdeploy-plugin-qt (${APPIMAGE_ARCH})"
        )
        add_custom_target(
          DownloadLinuxDeployQtPlugin
          DEPENDS "${LINUXDEPLOY_QT_PLUGIN}"
        )
        set(
          LINUXDEPLOY_QT_PLUGIN_ARGS
          --plugin
          qt
        )
        set(
          APPIMAGE_QT_DEPENDS
          DownloadLinuxDeployQtPlugin
        )
      endif()

      add_custom_target(
        AppImage
        COMMAND
          ${CMAKE_COMMAND} --install ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>
          --prefix ${CMAKE_INSTALL_PREFIX}
        COMMAND
          ${CMAKE_COMMAND} -E env PATH=${LINUXDEPLOY_DIR}:$ENV{PATH}
          ${LINUXDEPLOY_EXECUTABLE} --appdir ${CMAKE_INSTALL_PREFIX}
          ${LINUXDEPLOY_QT_PLUGIN_ARGS} --output appimage
        DEPENDS ${PROJECT_NAME}
                DownloadLinuxDeploy
                ${APPIMAGE_QT_DEPENDS}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>
      )
    elseif(
      APPLE
      AND NOT
          IOS
    )
      if(
        Qt6_FOUND
      )
        find_program(
          MACDEPLOYQT_EXECUTABLE
          NAMES macdeployqt
          HINTS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/Qt6/bin"
          NO_DEFAULT_PATH
        )

        if(
          NOT
          MACDEPLOYQT_EXECUTABLE
        )
          message(
            FATAL_ERROR
              "${PROJECT_NAME}: macdeployqt not found, check qtbase was built for triplet ${VCPKG_TARGET_TRIPLET}"
          )
        endif()

        add_custom_command(
          TARGET ${PROJECT_NAME}
          POST_BUILD
          COMMAND
            ${MACDEPLOYQT_EXECUTABLE} $<TARGET_BUNDLE_DIR:${PROJECT_NAME}>
            -qmldir=${CMAKE_CURRENT_SOURCE_DIR}/sources/qt/qml
            $<$<CONFIG:Debug>:-use-debug-libs>
          COMMAND_EXPAND_LISTS
          COMMENT
            "Deploying Qt runtime into $<TARGET_BUNDLE_DIR:${PROJECT_NAME}>"
          VERBATIM
        )
      endif()

      install(
        DIRECTORY "$<TARGET_BUNDLE_DIR:${PROJECT_NAME}>"
        DESTINATION .
        CONFIGURATIONS Debug
                       Release
      )

      # fixup_bundle mutates the installed copy: resolves every non-system
      # dependency via otool, copies it into Contents/Frameworks, and rewrites
      # install names/rpaths via install_name_tool. Must run at install time,
      # after the bundle above already exists on disk.
      install(
        CODE
          "
          include(BundleUtilities)
           fixup_bundle(
             \"\${CMAKE_INSTALL_PREFIX}/$<TARGET_FILE_BASE_NAME:${PROJECT_NAME}>.app\"
             \"\"
             \"${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<IF:$<CONFIG:Debug>,debug/lib,lib>\"
           )
          "
      )
    endif()
  elseif(
    EMSCRIPTEN
  )
    # JavaScript + WebAssembly
    install(
      FILES "${CMAKE_SOURCE_DIR}/_headers"
            "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/qtloader.js"
            "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/qtlogo.svg"
            "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${PROJECT_NAME}.js"
            "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${PROJECT_NAME}.wasm"
      DESTINATION bin
    )

    install(
      FILES "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${PROJECT_NAME}.html"
      DESTINATION bin
      RENAME "index.html"
    )

    # Favicon
    install(
      FILES "${PROJECT_ICON_DIR}/web/favicon.ico"
      DESTINATION bin
    )
  endif()
elseif(
  Qt6_FOUND
  AND NOT
      USE_VCPKG
)
  qt_generate_deploy_qml_app_script(
    TARGET
    ${PROJECT_NAME}
    OUTPUT_SCRIPT
    deploy_script
  )

  install(
    SCRIPT ${deploy_script}
  )
endif()

file(
  GLOB_RECURSE
  ALL_CMAKELISTS_FILES
  CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
)
message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "ALL_CMAKELISTS_FILES: ${ALL_CMAKELISTS_FILES}"
)

add_custom_target(
  cmake_format
  COMMAND
    cmake-format -i ${ALL_CMAKELISTS_FILES}
  COMMENT "Running cmake_format custom target"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  USES_TERMINAL
)

# Custom target to remove the install directory
add_custom_target(
  remove_install_dir
  COMMAND
    ${CMAKE_COMMAND} -E remove_directory "${CMAKE_CURRENT_BINARY_DIR}/install"
  COMMENT "Removing the install directory"
)

# Ensure cmake_format runs before building the main target
find_program(
  CMAKE_FORMAT_EXECUTABLE
  cmake-format
)
if(
  CMAKE_FORMAT_EXECUTABLE
)
  add_dependencies(
    ${PROJECT_NAME}
    cmake_format
  )
endif()

# Ensure remove_install_dir runs before building the main target
add_dependencies(
  ${PROJECT_NAME}
  remove_install_dir
)

# CPack packaging
set(
  CPACK_PACKAGE_NAME
  "${PROJECT_NAME}"
)
set(
  CPACK_PACKAGE_VENDOR
  ${PROJECT_VENDOR}
)
set(
  CPACK_PACKAGE_DESCRIPTION_SUMMARY
  "${PROJECT_NAME} - Qt QML based client application with GUI"
)
set(
  CPACK_PACKAGE_VERSION
  "${PROJECT_VERSION}"
)
set(
  CPACK_RESOURCE_FILE_LICENSE
  "${CMAKE_SOURCE_DIR}/LICENSE"
)

if(
  WIN32
)
  set(
    CPACK_GENERATOR
    "NSIS;ZIP"
  )
  set(
    CPACK_NSIS_DISPLAY_NAME
    "${PROJECT_NAME}"
  )
  set(
    CPACK_NSIS_PACKAGE_NAME
    "${PROJECT_NAME}"
  )

  file(
    GLOB
    PROJECT_ICON
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/sources/resources/assets/icons/bundle/light/squared/windows/*.ico"
  )
  message(
    STATUS "PROJECT_NAME: ${PROJECT_NAME} "
           "PROJECT_ICON: ${PROJECT_ICON}"
  )

  set(
    CPACK_NSIS_MUI_ICON
    "${PROJECT_ICON}"
  )
  set(
    CPACK_NSIS_MUI_UNIICON
    "${PROJECT_ICON}"
  )
  set(
    CPACK_NSIS_INSTALLED_ICON_NAME
    "bin/${PROJECT_NAME}.exe"
  )
  set(
    CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL
    ON
  )
  set(
    CPACK_NSIS_MODIFY_PATH
    OFF
  )

  # Start Menu + Desktop shortcuts
  set(
    CPACK_NSIS_CREATE_ICONS_EXTRA
    "
    CreateShortCut '$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\${PROJECT_NAME}.lnk' '$INSTDIR\\\\bin\\\\${PROJECT_NAME}.exe'
    CreateShortCut '$DESKTOP\\\\${PROJECT_NAME}.lnk' '$INSTDIR\\\\bin\\\\${PROJECT_NAME}.exe'
    "
  )

  set(
    CPACK_NSIS_DELETE_ICONS_EXTRA
    "
    Delete '$SMPROGRAMS\\\\$START_MENU\\\\${PROJECT_NAME}.lnk'
    Delete '$DESKTOP\\\\${PROJECT_NAME}.lnk'
    "
  )

  # Metadata for the installer .exe itself (Properties > Details tab)
  set(
    CPACK_NSIS_DEFINES
    "
    VIProductVersion '${PROJECT_VERSION}'
    VIFileVersion '${PROJECT_VERSION}'
    VIAddVersionKey /LANG=0 'ProductName' '${PROJECT_NAME}'
    VIAddVersionKey /LANG=0 'ProductVersion' '${PROJECT_VERSION}'
    VIAddVersionKey /LANG=0 'CompanyName' '${CPACK_PACKAGE_VENDOR}'
    VIAddVersionKey /LANG=0 'LegalCopyright' '(c) ${PROJECT_AUTHOR}'
    VIAddVersionKey /LANG=0 'FileDescription' '${CPACK_PACKAGE_DESCRIPTION_SUMMARY}'
    VIAddVersionKey /LANG=0 'FileVersion' '${PROJECT_VERSION}'
    "
  )

  set(
    CPACK_NSIS_EXTRA_INSTALL_COMMANDS
    "
    IfFileExists '$INSTDIR\\\\bin\\\\vc_redist.x64.exe' 0 +2
    ExecWait '$INSTDIR\\\\bin\\\\vc_redist.x64.exe /install /quiet /norestart'
    "
  )
elseif(
  UNIX
  AND NOT
      APPLE
  AND NOT
      ANDROID
  AND NOT
      EMSCRIPTEN
)
  set(
    CPACK_GENERATOR
    "DEB;TGZ"
  )
  set(
    CPACK_DEBIAN_PACKAGE_MAINTAINER
    "${PROJECT_AUTHOR} <https://github.com/${PROJECT_AUTHOR}>"
  )
  set(
    CPACK_DEBIAN_SECTION
    "utils"
  )
  set(
    CPACK_DEBIAN_PACKAGE_HOMEPAGE
    "https://github.com/${PROJECT_AUTHOR}/my-qt-qml-pro-projects-showcase/tree/qt-qml-deploy-to-desktop-mobile-and-embedded/${PROJECT_NAME}"
  )
  set(
    CPACK_DEBIAN_PACKAGE_SHLIBDEPS
    ON
  )
elseif(
  APPLE
  AND NOT
      IOS
)
  set(
    CPACK_GENERATOR
    "DragNDrop;TGZ"
  )
  set(
    CPACK_DMG_VOLUME_NAME
    "${PROJECT_NAME}"
  )
  set(
    CPACK_BUNDLE_NAME
    "${PROJECT_NAME}"
  )
  set(
    CPACK_PACKAGE_VERSION
    "${PROJECT_VERSION}"
  )
endif()

include(
  CPack
)
