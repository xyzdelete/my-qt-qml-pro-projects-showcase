cmake_minimum_required(
  VERSION 4.4.1
)

project(
  StaticLibModuleExample
  VERSION 1.0.0.0
  LANGUAGES CXX
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
message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "CPP_HEADERS: ${CPP_HEADERS}"
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
  CPP_FILES
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/cpp/files/*.cpp
)
message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "CPP_FILES: ${CPP_FILES}"
)

target_sources(
  ${PROJECT_NAME}
  PRIVATE ${CPP_FILES}
  PRIVATE FILE_SET
          HEADERS
          FILES
          ${CPP_HEADERS}
)

# AppleClang ships no C++20 module dependency scanner (clang-scan-deps), so
# CMake cannot scan/build a CXX_MODULES FILE_SET there (see
# CMAKE_CXX_SCAN_FOR_MODULES=OFF in the osx CMake presets). Only wire up the
# module file set on toolchains that actually support scanning; Apple
# consumers use the *Apple.hpp/.cpp header fallback instead.
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

target_include_directories(
  ${PROJECT_NAME}
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/sources/cpp/headers
)
