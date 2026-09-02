set(
  MODULE_NAME
  JavaScriptIndirectImport
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
  JavaScriptIndirectImport.qml
  utilities1.js
  utilities2.js
)
