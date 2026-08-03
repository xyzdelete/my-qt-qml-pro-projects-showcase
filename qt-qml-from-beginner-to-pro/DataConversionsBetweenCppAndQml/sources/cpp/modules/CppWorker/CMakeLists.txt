cmake_minimum_required(
  VERSION 4.3.2
)

project(
  CppWorkerModule
  VERSION 1.0
  LANGUAGES CXX
)

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
set(
  CMAKE_EXPORT_COMPILE_COMMANDS
  ON
)

add_library(
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
  CPP_MODULES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/cpp/modules/*.cppm
)

file(
  GLOB
  CPP_FILES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/cpp/files/*.cpp
)

target_sources(
  ${PROJECT_NAME}
  PRIVATE ${CPP_FILES}
  PRIVATE FILE_SET
          HEADERS
          FILES
          ${CPP_HEADERS}
  PRIVATE FILE_SET
          CXX_MODULES
          FILES
          ${CPP_MODULES}
)

target_compile_options(
  ${PROJECT_NAME}
  PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/utf-8>
)
