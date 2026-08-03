cmake_minimum_required(
  VERSION 4.4.1
)

project(
  Qt6QmlForBeginners
  VERSION 1.0.0.0
  LANGUAGES CXX
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
  ANDROID
  OR IOS
)
  find_package(
    Qt6
    ${QT_MINIMUM_VERSION}
    REQUIRED
    COMPONENTS Qml
               Quick
               QuickControls2
               Network
               Widgets
  )
elseif(
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
               Qml
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
    COMPONENTS Qml
               Quick
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
  CORE_CPP_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/core/modules/*
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "CORE_CPP_MODULES_DIRS: ${CORE_CPP_MODULES_DIRS}"
)

file(
  GLOB
  QT_QML_MODULES_DIRS
  LIST_DIRECTORIES true
  CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  sources/qt/modules/*
)
message(
  STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME} "
         "QT_QML_MODULES_DIRS: ${QT_QML_MODULES_DIRS}"
)

set(
  MAIN_TARGET_NAME
  DemoApp
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
  endif()
endforeach()

# Main must be configured after the modules it depends on.
add_subdirectory(
  "${CMAKE_CURRENT_SOURCE_DIR}/sources/qt/modules/${MAIN_TARGET_NAME}"
)