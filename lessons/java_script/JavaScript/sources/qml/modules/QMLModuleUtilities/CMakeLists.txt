set(
  MODULE_NAME
  QMLModuleUtilities
)

qt_add_library(
  ${MODULE_NAME}
  STATIC
)

target_link_libraries(
  ${MODULE_NAME}
  PRIVATE Qt6::Quick
)

set_source_files_properties(
  constants/Constants.qml
  PROPERTIES QT_QML_SINGLETON_TYPE
             TRUE
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
  QMLModuleUtilities.qml
  utilities/Utils.js
  constants/Constants.qml
  components/MButton.qml
)
