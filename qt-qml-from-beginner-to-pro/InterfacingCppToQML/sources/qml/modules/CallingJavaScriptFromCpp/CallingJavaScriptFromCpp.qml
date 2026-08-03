pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import QtQuick.Dialogs
import QtCore
import QtQuick.LocalStorage

ApplicationWindow {
  id: rootId
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  function qmlJSFunction(param) {
    print(" QML Talking, C++ called me with parameter : " + param + "returning back something");
    return "This is QML, over to you C++. Thanks for the Call.";
  }

  Button {
    id: mButton
    text: "Call QML function from C++"
    onClicked: {
      QmlJsCaller.cppMethod("QML Calling... ");
    }
  }
}
