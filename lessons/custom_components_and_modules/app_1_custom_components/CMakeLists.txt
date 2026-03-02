cmake_minimum_required(
  VERSION 4.2.3
)

project(
  app_1_custom_components
  VERSION 1.0
  LANGUAGES CXX
)

set(
  CMAKE_CXX_STANDARD_REQUIRED
  ON
)
set(
  CMAKE_CXX_STANDARD
  23
)
set(
  CMAKE_CXX_EXTENSIONS
  OFF
)
set(
  CMAKE_CXX_SCAN_FOR_MODULES
  ON
)

set(
  CMAKE_CXX_STANDARD_REQUIRED
  ON
)

find_package(
  Qt6
  REQUIRED
  COMPONENTS Quick
)

qt_standard_project_setup(
  REQUIRES
  6.8
)

qt_add_executable(
  ${CMAKE_PROJECT_NAME}
  sources/cpp/files/main.cpp
)

qt_add_qml_module(
  ${CMAKE_PROJECT_NAME}
  URI
  ${CMAKE_PROJECT_NAME}
  QML_FILES
  sources/qml/components/Main.qml
  sources/qml/components/MButton.qml
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

add_custom_target(
  cmake_format
  COMMAND
    cmake-format -i ${CMAKE_SOURCE_DIR}/CMakeLists.txt
  COMMENT "Running cmake_format custom target"
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  USES_TERMINAL
)

# Ensure cmake_format runs before building the main target across generators.
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
