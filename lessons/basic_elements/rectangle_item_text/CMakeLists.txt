cmake_minimum_required(
  VERSION 3.16
)

project(
  rectangle_item_text
  VERSION 0.1
  LANGUAGES CXX
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
  apprectangle_item_text
  main.cpp
)

qt_add_qml_module(
  apprectangle_item_text
  URI
  rectangle_item_text
  QML_FILES
  Main.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1. If
# you are developing for iOS or macOS you should consider setting an explicit,
# fixed bundle identifier manually though.
set_target_properties(
  apprectangle_item_text
  PROPERTIES # MACOSX_BUNDLE_GUI_IDENTIFIER com.example.apprectangle_item_text
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
  apprectangle_item_text
  PRIVATE Qt6::Quick
)

include(
  GNUInstallDirs
)
install(
  TARGETS apprectangle_item_text
  BUNDLE DESTINATION .
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
