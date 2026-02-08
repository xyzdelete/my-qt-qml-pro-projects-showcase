cmake_minimum_required(
  VERSION 4.4.1
)

project(
  Ch01FirstStepsWithQtQML
  VERSION 1.0.0.0
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
  IMPORTS
  TARGET
  S01Intro
  SOURCES
  ${CPP_HEADERS}
  ${CPP_FILES}
  RESOURCES
  ${RESOURCES}
)

# AppleClang ships no C++20 module dependency scanner (clang-scan-deps), so
# CMake cannot scan/build a CXX_MODULES FILE_SET there (see
# CMAKE_CXX_SCAN_FOR_MODULES=OFF in the osx CMake presets).
if(
  CPP_MODULES
  AND NOT
      APPLE
)
  target_sources(
    ${PROJECT_NAME}
    PUBLIC FILE_SET
           CXX_MODULES
           FILES
           ${CPP_MODULES}
  )
endif()

target_link_libraries(
  ${PROJECT_NAME}
  PUBLIC Qt6::QuickControls2
         Qt6::Network
         Qt6::Widgets
         S01Intro
)

target_include_directories(
  ${PROJECT_NAME}
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/sources/cpp/headers
)
