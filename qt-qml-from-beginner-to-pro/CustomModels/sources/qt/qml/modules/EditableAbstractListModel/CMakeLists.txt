cmake_minimum_required(
  VERSION 4.3.2
)

project(
  EditableAbstractListModel
  VERSION 1.0
  LANGUAGES CXX
)

qt_add_library(
  ${PROJECT_NAME}
  STATIC
)

file(
  GLOB
  CPP_HEADERS
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/cpp/headers/*.hpp
)

file(
  GLOB
  CPP_FILES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/cpp/files/*.cpp
)

file(
  GLOB
  CPP_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/cpp/modules/*
)

file(
  GLOB
  QML_FILES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qml/files/*.qml
)
file(
  GLOB_RECURSE
  RESOURCES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/resources/*
)

qt_add_qml_module(
  ${PROJECT_NAME}
  URI
  ${PROJECT_NAME}
  RESOURCE_PREFIX
  /${CMAKE_PROJECT_NAME}
  OUTPUT_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}
  QML_FILES
  ${QML_FILES}
  IMPORT_PATH
  ${CMAKE_CURRENT_BINARY_DIR}
  SOURCES
  ${CPP_HEADERS}
  ${CPP_FILES}
  RESOURCES
  ${RESOURCES}
)

target_link_libraries(
  ${PROJECT_NAME}
  PUBLIC Qt6::Quick
         Qt6::QuickControls2
)

target_include_directories(
  ${PROJECT_NAME}
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/sources/cpp/headers
)
