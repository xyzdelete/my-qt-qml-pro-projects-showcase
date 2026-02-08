cmake_minimum_required(
  VERSION 4.4.2
)

project(
  QtQmlDeployToDesktopMobileAndEmbedded
  VERSION 1.0.0.0
  LANGUAGES CXX
)

# CMake leaves CMAKE_SYSROOT empty for unified-toolchain NDKs; derive it from
# CMake's own auto-detected host tag instead of hardcoding it per-preset.
if(
  ANDROID
  AND NOT
      CMAKE_SYSROOT
)
  set(
    CMAKE_SYSROOT
    "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/${CMAKE_ANDROID_NDK_TOOLCHAIN_HOST_TAG}/sysroot"
    CACHE PATH "Android NDK unified toolchain sysroot (auto-derived)"
  )
endif()

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
  AND NOT
      EMSCRIPTEN
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
  CORE_CPP_TOPMODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/core/modules/*
)
set(CORE_CPP_MODULES_DIRS ${CORE_CPP_TOPMODULES_DIRS})
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "CORE_CPP_MODULES_DIRS: ${CORE_CPP_MODULES_DIRS}"
)

file(
  GLOB
  QT_QML_SUBMODULES
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qt/modules/*/sources/modules/*
)

file(
  GLOB
  QT_QML_TOPMODULES
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qt/modules/*
)

set(QT_QML_MODULES_DIRS ${QT_QML_SUBMODULES} ${QT_QML_TOPMODULES})
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "QT_QML_MODULES_DIRS: ${QT_QML_MODULES_DIRS}"
)

set(
  MAIN_TARGET_NAME
  RESTClientApp
)

add_library(project_warnings INTERFACE)

target_compile_options(project_warnings INTERFACE
  # MSVC
  $<$<CXX_COMPILER_ID:MSVC>:/W4>
  $<$<CXX_COMPILER_ID:MSVC>:/WX>
  $<$<CXX_COMPILER_ID:MSVC>:/permissive->
  $<$<CXX_COMPILER_ID:MSVC>:/utf-8>
  # /wd5050: MSVC's pre-compiled std module lacks /utf-8,
  # causing a false C5050
  $<$<CXX_COMPILER_ID:MSVC>:/wd5050>
  # /wd4702: false-positive "unreachable code" from inlined/optimized Qt
  # template code (e.g. qjsengine.h); -external:W0 doesn't catch it because
  # C4702 is attributed post-inlining, not to the header's location
  $<$<CXX_COMPILER_ID:MSVC>:/wd4702>
  $<$<CXX_COMPILER_ID:MSVC>:/translateInclude>
  $<$<CXX_COMPILER_ID:MSVC>:/bigobj>

  # GCC / GNU
  $<$<CXX_COMPILER_ID:GNU>:-Wall>
  $<$<CXX_COMPILER_ID:GNU>:-Wextra>
  $<$<CXX_COMPILER_ID:GNU>:-Wpedantic>
  $<$<CXX_COMPILER_ID:GNU>:-Werror>

  # Clang
  $<$<CXX_COMPILER_ID:Clang>:-Wall>
  $<$<CXX_COMPILER_ID:Clang>:-Wextra>
  $<$<CXX_COMPILER_ID:Clang>:-Wpedantic>
  $<$<CXX_COMPILER_ID:Clang>:-Werror>
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

    get_filename_component(TARGET_NAME "${dir}" NAME)
    message(STATUS "TARGET: ${TARGET_NAME}")

    target_link_libraries(
      ${TARGET_NAME}
      PRIVATE project_warnings
    )
  endif()
endforeach()

# Main must be configured after the modules it depends on.
add_subdirectory(
  "${CMAKE_CURRENT_SOURCE_DIR}/sources/qt/modules/${MAIN_TARGET_NAME}"
)

target_link_libraries(
  ${MAIN_TARGET_NAME}
  PRIVATE project_warnings
)