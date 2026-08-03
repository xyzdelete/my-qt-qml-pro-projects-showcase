pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import QtQuick.Dialogs
import QtCore

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  Rectangle {
    id: rectId
    anchors.fill: parent
    color: "red"

    MouseArea {
      anchors.fill: parent
      onClicked: function () {
        colorDialogId.open();
      }

      ColorDialog {
        id: colorDialogId
        title: "choose color"
        onAccepted: function () {
          rectId.color = selectedColor;
        }
        onRejected: function () {
          print("Dialog rejected");
        }
      }
    }
  }

  Settings {
    category: "window"
    property alias x: rootId.x
    property alias y: rootId.y
    property alias width: rootId.width
    property alias height: rootId.height
  }
  Settings {
    category: "colors"
    property alias rectColor: rectId.color
  }
}
