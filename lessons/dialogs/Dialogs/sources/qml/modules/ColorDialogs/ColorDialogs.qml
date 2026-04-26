import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Dialogs

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  Column {
    spacing: 20
    anchors.centerIn: parent

    Button {
      text: "Choose color"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: function() {
        colorDialogId.open()
      }
    }

    Rectangle {
      id: rectangleId
      width: 200
      height: 200
      border.color: "black"
      border.width: 8
      anchors.horizontalCenter: parent.horizontalCenter
    }

    ColorDialog {
      id: colorDialogId
      title: "Choose color"
      onAccepted: function() {
        print("Chosen color: " + selectedColor)
        rectangleId.color = selectedColor
      }
      onRejected: function() {
        print("User rejected the dialog")
      }
    }
  }
}
