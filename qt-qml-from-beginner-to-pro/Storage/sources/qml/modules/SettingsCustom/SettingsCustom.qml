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
  width: windowSettingsId.width
  height: windowSettingsId.height
  x: windowSettingsId.x
  y: windowSettingsId.y
  visible: true
  Material.foreground: "black"

  Rectangle {
    id: rectId
    anchors.fill: parent
    color: colorSettingsId.rectColor

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
    id: windowSettingsId
    category: "window"
    property int x: 300
    property int y: 300
    property int width: 1280
    property int height: 720
  }
  Settings {
    id: colorSettingsId
    category: "colors"
    property color rectColor: "red"
  }

  Component.onDestruction: function () {
    // Save position and size
    windowSettingsId.x = rootId.x;
    windowSettingsId.y = rootId.y;
    windowSettingsId.width = rootId.width;
    windowSettingsId.height = rootId.height;
    // Save the color
    colorSettingsId.rectColor = rectId.color;
  }
}
