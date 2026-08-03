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

  Row {
    spacing: 10
    Rectangle {
      id: redRectId
      width: 100
      height: 100
      color: "red"
      MouseArea {
        id: redRectMouseAreaId
        anchors.fill: parent
      }
    }
    Rectangle {
      id: greenRectId
      width: 100
      height: 100
      color: "green"
      Connections {
        target: redRectMouseAreaId
        function onClicked() {
          print("This is the green rectangle responding");
        }
      }
    }
    Rectangle {
      id: blueRectId
      width: 100
      height: 100
      color: "blue"
      Connections {
        target: redRectMouseAreaId
        function onClicked() {
          print("This is the blue rectangle responding");
        }
      }
    }
  }
}
