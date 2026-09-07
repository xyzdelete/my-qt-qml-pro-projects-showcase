cmake_minimum_required(
  VERSION 4.4.1
)

project(
  Qt6QmlForBeginners
  VERSION 1.0.0.0
  LANGUAGES CXX
)

message(
  STATUS "CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME} "
         "CMAKE_HOST_SYSTEM_PROCESSOR: ${CMAKE_HOST_SYSTEM_PROCESSOR} "
         "CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME} "
         "CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR} "
         "CMAKE_CROSSCOMPILING: ${CMAKE_CROSSCOMPILING} "
         "CMAKE_C_COMPILER: ${CMAKE_C_COMPILER} "
         "CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}"
)

set(
  QT_MINIMUM_VERSION
  6.8.0
)

message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}"
)

if(
  UNIX
  AND NOT
      APPLE
  AND NOT
      ANDROID
)
  include(
    CTest
  )

  find_package(
    Qt6
    ${QT_MINIMUM_VERSION}
    REQUIRED
    COMPONENTS DBus
               Quick
               QuickControls2
               QuickTest
               Network
               Test
               Widgets
  )
else()
  include(
    CTest
  )

  find_package(
    Qt6
    ${QT_MINIMUM_VERSION}
    REQUIRED
    COMPONENTS Quick
               QuickControls2
               QuickTest
               Network
               Test
               Widgets
  )
endif()

qt_standard_project_setup(
  REQUIRES
  ${QT_MINIMUM_VERSION}
)

file(
  GLOB
  CORE_CPP_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/core/modules/*
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "CORE_CPP_MODULES_DIRS: ${CORE_CPP_MODULES_DIRS}"
)

file(
  GLOB
  QT_QML_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qt/modules/*
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "QT_QML_MODULES_DIRS: ${QT_QML_MODULES_DIRS}"
)

set(
  MAIN_TARGET_NAME
  DemoApp
)

foreach(
  dir
  IN
  LISTS QT_QML_MODULES_DIRS
        CORE_CPP_MODULES_DIRS
)
  if(
    IS_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}/${dir}
    AND EXISTS
        ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/CMakeLists.txt
    AND NOT
        dir
        STREQUAL
        "sources/qt/modules/${MAIN_TARGET_NAME}"
  )
    add_subdirectory(
      ${CMAKE_CURRENT_SOURCE_DIR}/${dir}
    )
  endif()
endforeach()

# Main must be configured after the modules it depends on.
add_subdirectory(
  "${CMAKE_CURRENT_SOURCE_DIR}/sources/qt/modules/${MAIN_TARGET_NAME}"
)

# CPack packaging configuration
set(
  PROJECT_AUTHOR
  "xyzdelete"
)
set(
  CPACK_PACKAGE_NAME
  "${MAIN_TARGET_NAME}"
)
set(
  CPACK_PACKAGE_VENDOR
  "com.github.${PROJECT_AUTHOR}"
)
set(
  CPACK_PACKAGE_DESCRIPTION_SUMMARY
  "${MAIN_TARGET_NAME} - Qt QML based client application with GUI"
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
    "${MAIN_TARGET_NAME}"
  )
  set(
    CPACK_NSIS_PACKAGE_NAME
    "${MAIN_TARGET_NAME}"
  )

  file(
    GLOB
    PROJECT_ICON
    CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/sources/resources/assets/icons/bundle/light/squared/windows/*.ico"
  )
  message(
    STATUS "PROJECT_NAME: ${MAIN_TARGET_NAME} "
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
    "bin/${MAIN_TARGET_NAME}.exe"
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
    CreateShortCut '$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\${MAIN_TARGET_NAME}.lnk' '$INSTDIR\\\\bin\\\\${MAIN_TARGET_NAME}.exe'
    CreateShortCut '$DESKTOP\\\\${MAIN_TARGET_NAME}.lnk' '$INSTDIR\\\\bin\\\\${MAIN_TARGET_NAME}.exe'
    "
  )

  set(
    CPACK_NSIS_DELETE_ICONS_EXTRA
    "
    Delete '$SMPROGRAMS\\\\$START_MENU\\\\${MAIN_TARGET_NAME}.lnk'
    Delete '$DESKTOP\\\\${MAIN_TARGET_NAME}.lnk'
    "
  )

  # Metadata for the installer .exe itself (Properties > Details tab)
  set(
    CPACK_NSIS_DEFINES
    "
    VIProductVersion '${PROJECT_VERSION}'
    VIFileVersion '${PROJECT_VERSION}'
    VIAddVersionKey /LANG=0 'ProductName' '${MAIN_TARGET_NAME}'
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
    "https://github.com/${PROJECT_AUTHOR}/my-qt-qml-pro-projects-showcase"
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
    "${MAIN_TARGET_NAME}"
  )
  set(
    CPACK_BUNDLE_NAME
    "${MAIN_TARGET_NAME}"
  )
  set(
    CPACK_PACKAGE_VERSION
    "${PROJECT_VERSION}"
  )
endif()

include(
  CPack
)