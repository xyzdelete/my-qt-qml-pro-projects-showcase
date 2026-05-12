pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import QtQuick.Dialogs
import QtCore
import QtQuick.LocalStorage
//import InstantiableObject
import instantiable.object.movie
import my.custom.singleton

ApplicationWindow {
  id: rootId
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  Button {
    id: buttonId
    text: "Click"
    onClicked: function () {
      MySingleton.doSomething();
    }
  }
}
