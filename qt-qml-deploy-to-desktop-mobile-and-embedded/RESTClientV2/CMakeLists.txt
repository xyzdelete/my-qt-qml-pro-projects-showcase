cmake_minimum_required(
  VERSION 4.3.3
)

project(
  RESTClientV2Project
  VERSION 1.0
  LANGUAGES CXX
)

find_package(
  Qt6
  REQUIRED
  COMPONENTS Quick
             QuickControls2
)

qt_standard_project_setup()

qt_policy(
  SET
  QTP0004
  NEW
)

qt_add_executable(
  ${CMAKE_PROJECT_NAME}
)

file(
  GLOB
  CORE_CPP_MAIN
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/core/cpp/main/*.cpp
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "CORE_CPP_MAIN: ${CORE_CPP_MAIN}"
)

file(
  GLOB
  CORE_CPP_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/core/cpp/modules/*
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "CORE_CPP_MODULES_DIRS: ${CORE_CPP_MODULES_DIRS}"
)

file(
  GLOB
  QT_QML_MAIN
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qt/qml/main/*.qml
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "QT_QML_MAIN: ${QT_QML_MAIN}"
)

file(
  GLOB
  QT_QML_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qt/qml/modules/*
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "QT_QML_MODULES_DIRS: ${QT_QML_MODULES_DIRS}"
)

file(
  GLOB
  QT_QML_IMPORT_PATH_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_BINARY_DIR}/sources/qt/qml/modules/*
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "QT_QML_IMPORT_PATH_MODULES_DIRS: ${QT_QML_IMPORT_PATH_MODULES_DIRS}"
)

file(
  GLOB
  QT_CPP_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qt/cpp/modules/*
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "QT_CPP_MODULES_DIRS: ${QT_CPP_MODULES_DIRS}"
)

file(
  GLOB_RECURSE
  RESOURCES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/resources/*
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "RESOURCES: ${RESOURCES}"
)

qt_add_qml_module(
  ${CMAKE_PROJECT_NAME}
  URI
  ${CMAKE_PROJECT_NAME}
  RESOURCE_PREFIX
  /${CMAKE_PROJECT_NAME}
  OUTPUT_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}
  QML_FILES
  ${QT_QML_MAIN}
  IMPORT_PATH
  ${QT_QML_IMPORT_PATH_MODULES_DIRS}
  SOURCES
  ${CORE_CPP_MAIN}
  RESOURCES
  ${RESOURCES}
)

foreach(
  dir
  IN
  LISTS QT_QML_MODULES_DIRS
        QT_CPP_MODULES_DIRS
        CORE_CPP_MODULES_DIRS
)
  if(
    IS_DIRECTORY
    ${CMAKE_CURRENT_SOURCE_DIR}/${dir}
    AND EXISTS
        ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/CMakeLists.txt
  )
    add_subdirectory(
      ${CMAKE_CURRENT_SOURCE_DIR}/${dir}
    )
  endif()
endforeach()

# ============================================================================
# Cross-Platform Icon Configuration
# ============================================================================

set(
  APP_ICONS_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/sources/resources/assets/icons/bundle/Light"
)

# Bundle / executable type flags are harmless on every platform. Qt for iOS sets
# MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1; uncomment the line
# below to pin an explicit identifier.
set_target_properties(
  ${CMAKE_PROJECT_NAME}
  PROPERTIES MACOSX_BUNDLE
             TRUE
             MACOSX_BUNDLE_BUNDLE_VERSION
             ${PROJECT_VERSION}
             MACOSX_BUNDLE_SHORT_VERSION_STRING
             ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
             # MACOSX_BUNDLE_GUI_IDENTIFIER com.${CMAKE_PROJECT_NAME}
             WIN32_EXECUTABLE
             TRUE
)

# ---- Windows ---------------------------------------------------------------
# RC file is added as a source which includes the icon

# Add Windows RC file with icon
if(
  WIN32
)
  file(
    GLOB
    WIN_ICONS_RC
    CONFIGURE_DEPENDS
    "${APP_ICONS_DIR}/windows/*.rc"
  )
  message(
    STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
           "WIN_ICONS_RC: ${WIN_ICONS_RC}"
  )

  target_sources(
    ${CMAKE_PROJECT_NAME}
    PRIVATE ${WIN_ICONS_RC}
  )
endif()

# ---- macOS -----------------------------------------------------------------
if(
  APPLE
  AND NOT
      IOS
)
  set(
    APP_MACOS_ICNS
    "${APP_ICONS_DIR}/macos/RESTClientV2-squared.icns"
  )
  target_sources(
    ${CMAKE_PROJECT_NAME}
    PRIVATE "${APP_MACOS_ICNS}"
  )
  set_source_files_properties(
    "${APP_MACOS_ICNS}"
    PROPERTIES MACOSX_PACKAGE_LOCATION
               Resources
  )
  set_target_properties(
    ${CMAKE_PROJECT_NAME}
    PROPERTIES MACOSX_BUNDLE_ICON_FILE
               RESTClientV2-squared.icns
  )
endif()

# ---- iOS -------------------------------------------------------------------
# Qt 6.5+: QT_IOS_ICON_FILES wires all sizes into Info.plist automatically.
if(
  IOS
)
  set(
    IOS_ICON_FILES
    "${APP_ICONS_DIR}/ios/AppIcon-1024.png"
    "${APP_ICONS_DIR}/ios/AppIcon-180.png"
    "${APP_ICONS_DIR}/ios/AppIcon-167.png"
    "${APP_ICONS_DIR}/ios/AppIcon-152.png"
    "${APP_ICONS_DIR}/ios/AppIcon-120.png"
    "${APP_ICONS_DIR}/ios/AppIcon-87.png"
    "${APP_ICONS_DIR}/ios/AppIcon-80.png"
    "${APP_ICONS_DIR}/ios/AppIcon-60.png"
    "${APP_ICONS_DIR}/ios/AppIcon-58.png"
    "${APP_ICONS_DIR}/ios/AppIcon-40.png"
  )
  set_target_properties(
    ${CMAKE_PROJECT_NAME}
    PROPERTIES QT_IOS_ICON_FILES
               "${IOS_ICON_FILES}"
  )
endif()

# ---- Android ---------------------------------------------------------------
# QT_ANDROID_PACKAGE_SOURCE_DIR overlays the APK template; icons are expected at
# res/mipmap-{density}/ic_launcher.png within that directory (which matches the
# output layout produced by generate-icons.py).
if(
  ANDROID
)
  set_target_properties(
    ${CMAKE_PROJECT_NAME}
    PROPERTIES QT_ANDROID_PACKAGE_SOURCE_DIR
               "${APP_ICONS_DIR}/android"
  )
endif()

# ---- Linux -----------------------------------------------------------------
# Modern DEs (GNOME, KDE, XFCE) render from the SVG at any size they need.
if(
  UNIX
  AND NOT
      APPLE
  AND NOT
      ANDROID
)
  install(
    FILES "${APP_ICONS_DIR}/linux/scalable/apps/RESTClientV2-square.svg"
    DESTINATION "share/icons/hicolor/scalable/apps"
    RENAME "${CMAKE_PROJECT_NAME}.svg"
  )
endif()

target_link_libraries(
  ${CMAKE_PROJECT_NAME}
  PRIVATE Qt6::Quick
          Qt6::QuickControls2
          CppWorkerModule
          RESTClientV2
          RESTClientV2plugin
)

message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}"
)

include(
  GNUInstallDirs
)

if(
  USE_VCPKG
)
  if(
    NOT
    VCPKG_STATIC_LIBS_LINKING
  )
    if(
      WIN32
    )
      install(
        TARGETS ${CMAKE_PROJECT_NAME}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
      )

      # Only do DLL/plugin install for dynamic builds
      install(
        FILES "$<TARGET_PDB_FILE:${CMAKE_PROJECT_NAME}>"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS Debug
      )
      install(
        DIRECTORY "${VCPKG_INSTALLED_DIR}/x64-windows/bin/"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS
          Release
          RelWithDebInfo
          MinSizeRel
        FILES_MATCHING
        PATTERN "*.dll"
      )
      install(
        DIRECTORY "${VCPKG_INSTALLED_DIR}/x64-windows/debug/bin/"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS Debug
        FILES_MATCHING
        PATTERN "*.dll"
        PATTERN "*.pdb"
      )
      install(
        DIRECTORY "${VCPKG_INSTALLED_DIR}/x64-windows/Qt6/plugins/"
        DESTINATION Qt6/plugins
        CONFIGURATIONS
          Release
          RelWithDebInfo
          MinSizeRel
      )
      install(
        DIRECTORY "${VCPKG_INSTALLED_DIR}/x64-windows/debug/Qt6/plugins/"
        DESTINATION Qt6/plugins
        CONFIGURATIONS Debug
      )
      install(
        DIRECTORY "${VCPKG_INSTALLED_DIR}/x64-windows/Qt6/qml/"
        DESTINATION Qt6/qml
        CONFIGURATIONS
          Release
          RelWithDebInfo
          MinSizeRel
      )
      install(
        DIRECTORY "${VCPKG_INSTALLED_DIR}/x64-windows/debug/Qt6/qml/"
        DESTINATION Qt6/qml
        CONFIGURATIONS Debug
      )

      set(
        QT_CONF_FILE
        "${CMAKE_CURRENT_BINARY_DIR}/qt.conf"
        CACHE PATH
              "Stores paths of required Qt components"
              FORCE
      )
      message(
        STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
               "QT_CONF_FILE: ${QT_CONF_FILE}"
      )
      file(
        WRITE
        "${QT_CONF_FILE}"
        "[Paths]\nPrefix = ..\nPlugins = Qt6/plugins\nQmlImports = Qt6/qml\n"
      )
      install(
        FILES "${QT_CONF_FILE}"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
      )
    endif()
  else()
    install(
      TARGETS ${CMAKE_PROJECT_NAME}
      BUNDLE DESTINATION .
      LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
      RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
  endif()
else()
  qt_generate_deploy_qml_app_script(
    TARGET
    ${CMAKE_PROJECT_NAME}
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
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
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

# Custom target to remove the package directory
add_custom_target(
  remove_package_dir
  COMMAND
    ${CMAKE_COMMAND} -E remove_directory "${CMAKE_CURRENT_BINARY_DIR}/package"
  COMMENT "Removing the package directory"
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
    ${CMAKE_PROJECT_NAME}
    cmake_format
  )
endif()

# Ensure remove_package_dir runs before building the main target
add_dependencies(
  ${CMAKE_PROJECT_NAME}
  remove_package_dir
)
