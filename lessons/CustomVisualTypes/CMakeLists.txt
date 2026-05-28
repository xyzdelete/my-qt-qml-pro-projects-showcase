cmake_minimum_required(
  VERSION 4.3.3
)

project(
  CustomVisualTypes
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

file(
  GLOB
  CORE_CPP_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/core/cpp/modules/*
)

file(
  GLOB
  QT_QML_MAIN
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qt/qml/main/*.qml
)

file(
  GLOB
  QT_QML_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qt/qml/modules/*
)

file(
  GLOB
  QT_QML_IMPORT_PATH_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_BINARY_DIR}/sources/qt/qml/modules/*
)

file(
  GLOB
  QT_CPP_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qt/cpp/modules/*
)

file(
  GLOB_RECURSE
  RESOURCES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/resources/*
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

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1. If
# you are developing for iOS or macOS you should consider setting an explicit,
# fixed bundle identifier manually though.
set_target_properties(
  ${CMAKE_PROJECT_NAME}
  PROPERTIES # MACOSX_BUNDLE_GUI_IDENTIFIER
             # com.example.${CMAKE_PROJECT_NAME}
             MACOSX_BUNDLE_BUNDLE_VERSION
             ${PROJECT_VERSION}
             MACOSX_BUNDLE_SHORT_VERSION_STRING
             ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
             MACOSX_BUNDLE
             TRUE
             WIN32_EXECUTABLE
             TRUE
)

target_link_libraries(
  ${CMAKE_PROJECT_NAME}
  PRIVATE Qt6::Quick
          Qt6::QuickControls2
          CppWorkerModule
          PaintingQMLItems
          PaintingQMLItemsplugin
)

set(
  CMAKE_INSTALL_PREFIX
  "${CMAKE_CURRENT_BINARY_DIR}/package/${CMAKE_PROJECT_NAME}"
  CACHE
    PATH
    "Root directory where project will be installed when run the install step"
    FORCE
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
        BUNDLE DESTINATION .
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
