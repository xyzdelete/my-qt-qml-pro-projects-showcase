set(
  MODULE_NAME
  ApplicationWindows
)

qt_add_library(
  ${MODULE_NAME}
  STATIC
)

target_link_libraries(
  ${MODULE_NAME}
  PRIVATE Qt6::Quick
)

qt_add_qml_module(
  ${MODULE_NAME}
  URI
  ${MODULE_NAME}
  RESOURCE_PREFIX
  /qt/qml
  OUTPUT_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}/${MODULE_NAME}
  QML_FILES
  ApplicationWindows.qml
  Page1.qml
  Page2.qml
  Page3.qml
  RESOURCES
  images/copyIcon.png
  images/cutIcon.png
  images/info.png
  images/newFileIcon.png
  images/openIcon.png
  images/pasteIcon.png
  images/quitIcon.png
  images/redoIcon.png
  images/saveAsIcon.png
  images/saveIcon.png
  images/undoIcon.png
)
