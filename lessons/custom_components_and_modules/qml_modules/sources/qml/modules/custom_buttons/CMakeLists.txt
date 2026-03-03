set(
  MODULE_NAME
  GreatButtons
)

qt_add_library(
  ${MODULE_NAME}
  STATIC
)

set_target_properties(
  ${MODULE_NAME}
  PROPERTIES AUTOMOC
             ON
)
target_link_libraries(
  ${MODULE_NAME}
  PRIVATE Qt6::Quick
)

qt_add_qml_module(
  ${MODULE_NAME}
  URI
  ${MODULE_NAME}
  VERSION
  1.0
  RESOURCE_PREFIX
  /qt/qml
  OUTPUT_DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}/${MODULE_NAME}
  QML_FILES
  GrayButton.qml
  GreenButton.qml
  RedButton.qml
  YellowButton.qml
)
