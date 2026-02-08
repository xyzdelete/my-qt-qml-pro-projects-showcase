cmake_minimum_required(
  VERSION 4.4.2
)

project(
  CV
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
    CACHE PATH
          "Android NDK unified toolchain sysroot (auto-derived)"
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
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
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
               Linguist
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
               Linguist
  )
endif()

qt_standard_project_setup(
  REQUIRES
  ${QT_MINIMUM_VERSION}
)

add_library(
  project_warnings
  INTERFACE
)

target_compile_options(
  project_warnings
  INTERFACE # MSVC
            $<$<CXX_COMPILER_ID:MSVC>:/W4>
            $<$<CXX_COMPILER_ID:MSVC>:/WX>
            $<$<CXX_COMPILER_ID:MSVC>:/permissive->
            $<$<CXX_COMPILER_ID:MSVC>:/utf-8>
            # /wd5050: MSVC's pre-compiled std module lacks /utf-8, causing a
            # false C5050
            $<$<CXX_COMPILER_ID:MSVC>:/wd5050>
            # /wd4702: false-positive "unreachable code" from inlined/optimized
            # Qt template code (e.g. qjsengine.h); -external:W0 doesn't catch it
            # because C4702 is attributed post-inlining, not to the header's
            # location
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

file(
  GLOB
  MODULES
  CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/sources/modules/*/CMakeLists.txt"
)
set(
  MODULES_DIRS_NAMES
  ""
)
foreach(
  CMAKELISTS_FILE
  ${MODULES}
)
  get_filename_component(
    MODULE_DIR
    "${CMAKELISTS_FILE}"
    DIRECTORY
  )
  get_filename_component(
    MODULE_DIR_NAME
    "${MODULE_DIR}"
    NAME
  )
  list(
    APPEND
    MODULES_DIRS_NAMES
    "${MODULE_DIR_NAME}"
  )
endforeach()
message(
  STATUS "PROJECT_NAME: ${PROJECT_NAME} "
         "MODULES_DIRS_NAMES: ${MODULES_DIRS_NAMES}"
)
foreach(
  CMAKELISTS_FILE
  ${MODULES}
)
  get_filename_component(
    MODULE_DIR
    "${CMAKELISTS_FILE}"
    DIRECTORY
  )
  get_filename_component(
    MODULE_DIR_NAME
    "${MODULE_DIR}"
    NAME
  )
  add_subdirectory(
    ${MODULE_DIR}
  )
endforeach()

function(
  link_project_warnings_recursive
  BASE_DIR
)
  file(
    GLOB
    MODULES
    CONFIGURE_DEPENDS
    "${BASE_DIR}/sources/modules/*/CMakeLists.txt"
  )
  foreach(
    CMAKELISTS_FILE
    ${MODULES}
  )
    get_filename_component(
      MODULE_DIR
      "${CMAKELISTS_FILE}"
      DIRECTORY
    )
    get_filename_component(
      MODULE_DIR_NAME
      "${MODULE_DIR}"
      NAME
    )

    if(
      TARGET
      ${MODULE_DIR_NAME}
    )
      target_link_libraries(
        ${MODULE_DIR_NAME}
        PRIVATE project_warnings
      )
      message(
        STATUS "TARGET: project_warnings linked to TARGET: ${MODULE_DIR_NAME}"
      )
    endif()

    link_project_warnings_recursive(
      ${MODULE_DIR}
    )
  endforeach()
endfunction()

link_project_warnings_recursive(
  ${CMAKE_CURRENT_SOURCE_DIR}
)
