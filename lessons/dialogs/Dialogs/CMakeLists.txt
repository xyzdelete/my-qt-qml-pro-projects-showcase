cmake_minimum_required(
  VERSION 4.3.1
)

project(
  Dialogs
  VERSION 1.0
  LANGUAGES CXX
)

# Qt6 auto-discovery (Windows / MacOS / Android)
if(
  (NOT
   DEFINED
   Qt6_DIR
   OR Qt6_DIR
      STREQUAL
      ""
  )
  AND
    (NOT
     DEFINED
     CMAKE_PREFIX_PATH
     OR CMAKE_PREFIX_PATH
        STREQUAL
        ""
    )
)
  # Platform-specific search roots and toolkit suffixes
  if(
    WIN32
  )
    set(
      _qt_roots
      "C:/Qt"
    )
    set(
      _qt_toolkits
      msvc2026_64
      msvc2022_64
      msvc2019_64
      mingw_64
    )
  elseif(
    ANDROID
  )
    set(
      _qt_roots
      "$ENV{HOME}/Qt"
      "/opt/Qt"
    )
    set(
      _qt_toolkits
      android_arm64_v8a
      android_armv7
      android_x86_64
      android_x86
    )
  elseif(
    APPLE
  )
    set(
      _qt_roots
      "$ENV{HOME}/Qt"
      "/opt/Qt"
    )
    set(
      _qt_toolkits
      macos
    )
  else()
    set(
      _qt_roots
      "$ENV{HOME}/Qt"
      "/opt/Qt"
    )
    set(
      _qt_toolkits
      gcc_64
    )
  endif()

  # Scan each root for Qt 6.* versions, newest first
  foreach(
    _qt_root
    ${_qt_roots}
  )
    file(
      GLOB
      _qt_versions
      "${_qt_root}/6.*"
    )
    list(
      SORT
      _qt_versions
      COMPARE NATURAL
    )
    list(
      REVERSE
      _qt_versions
    )

    foreach(
      _qt_ver
      ${_qt_versions}
    )
      foreach(
        _qt_toolkit
        ${_qt_toolkits}
      )
        if(
          EXISTS
          "${_qt_ver}/${_qt_toolkit}/lib/cmake/Qt6"
        )
          set(
            QT6_INSTALL_PREFIX
            "${_qt_ver}/${_qt_toolkit}"
            CACHE PATH
                  "Path to Qt6 installation root"
                  FORCE
          )
          break()
        endif()
      endforeach()
      if(
        QT6_INSTALL_PREFIX
      )
        break()
      endif()
    endforeach()
    if(
      QT6_INSTALL_PREFIX
    )
      break()
    endif()
  endforeach()
endif()

# Guard: fail if QT6_INSTALL_PREFIX is not set
if(
  NOT
  QT6_INSTALL_PREFIX
)
  message(
    FATAL_ERROR "QT6_INSTALL_PREFIX was not detected!"
  )
endif()

message(
  STATUS "QT6_INSTALL_PREFIX: ${QT6_INSTALL_PREFIX}"
)

# Guard against duplicate
if(
  NOT
  "${QT6_INSTALL_PREFIX}"
  IN_LIST
  CMAKE_PREFIX_PATH
)
  list(
    APPEND
    CMAKE_PREFIX_PATH
    ${QT6_INSTALL_PREFIX}
  )
endif()

message(
  STATUS "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}"
)

if(
  NOT
  "${QT6_INSTALL_PREFIX}/qml"
  IN_LIST
  QML_IMPORT_PATH
)
  list(
    APPEND
    QML_IMPORT_PATH
    "${QT6_INSTALL_PREFIX}/qml"
  )
endif()

message(
  STATUS "QML_IMPORT_PATH: ${QML_IMPORT_PATH}"
)

if(
  NOT
  DEFINED
  QT_QML_GENERATE_QMLLS_INI
  OR QT_QML_GENERATE_QMLLS_INI
     STREQUAL
     ""
)
  set(
    QT_QML_GENERATE_QMLLS_INI
    ON
    CACHE STRING
          "Generate qmlls.ini files"
          FORCE
  )
endif()
message(
  STATUS "QT_QML_GENERATE_QMLLS_INI: ${QT_QML_GENERATE_QMLLS_INI}"
)

# C++ standard
set(
  CMAKE_CXX_STANDARD
  23
)
set(
  CMAKE_CXX_STANDARD_REQUIRED
  ON
)
set(
  CMAKE_CXX_EXTENSIONS
  OFF
)
set(
  CMAKE_CXX_SCAN_FOR_MODULES
  ON
)

find_package(
  Qt6
  6.11.0
  REQUIRED
  COMPONENTS Quick
             QuickControls2
)

qt_standard_project_setup()

qt_add_executable(
  ${CMAKE_PROJECT_NAME}
  ${CMAKE_CURRENT_SOURCE_DIR}/sources/cpp/files/main.cpp
)

qt_add_qml_module(
  ${CMAKE_PROJECT_NAME}
  URI
  ${CMAKE_PROJECT_NAME}
  RESOURCE_PREFIX
  /qt/qml
  OUTPUT_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}
  QML_FILES
  sources/qml/files/Main.qml
  IMPORT_PATH
  ${CMAKE_CURRENT_BINARY_DIR}/sources/qml/modules/ColorDialogs
  ${CMAKE_CURRENT_BINARY_DIR}/sources/qml/modules/FileDialogs
  ${CMAKE_CURRENT_BINARY_DIR}/sources/qml/modules/FolderDialogs
  ${CMAKE_CURRENT_BINARY_DIR}/sources/qml/modules/FontDialogs
)

add_subdirectory(
  ${CMAKE_CURRENT_SOURCE_DIR}/sources/qml/modules/ColorDialogs
)
add_subdirectory(
  ${CMAKE_CURRENT_SOURCE_DIR}/sources/qml/modules/FileDialogs
)
add_subdirectory(
  ${CMAKE_CURRENT_SOURCE_DIR}/sources/qml/modules/FolderDialogs
)
add_subdirectory(
  ${CMAKE_CURRENT_SOURCE_DIR}/sources/qml/modules/FontDialogs
)

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
          ColorDialogsplugin
          FileDialogsplugin
          FolderDialogsplugin
          FontDialogsplugin
)

set(
  CMAKE_INSTALL_PREFIX
  "${CMAKE_CURRENT_BINARY_DIR}/package/${CMAKE_PROJECT_NAME}"
  CACHE PATH
        "Install path"
        FORCE
)

include(
  GNUInstallDirs
)

install(
  TARGETS ${CMAKE_PROJECT_NAME}
  BUNDLE DESTINATION .
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

qt_generate_deploy_qml_app_script(
  TARGET
  ${CMAKE_PROJECT_NAME}
  OUTPUT_SCRIPT
  deploy_script
)

install(
  SCRIPT ${deploy_script}
)

add_custom_target(
  cmake_format
  COMMAND
    cmake-format -i ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/qml/modules/ColorDialogs/CMakeLists.txt
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/qml/modules/FileDialogs/CMakeLists.txt
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/qml/modules/FolderDialogs/CMakeLists.txt
    ${CMAKE_CURRENT_SOURCE_DIR}/sources/qml/modules/FontDialogs/CMakeLists.txt
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
