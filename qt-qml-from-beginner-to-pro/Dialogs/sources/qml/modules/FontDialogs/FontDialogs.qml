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
      text: "Choose a font"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: function() {
        fontDialogId.open()
      }
    }

    Text {
      id: textId
      text: "Hello World!"
      wrapMode: Text.Wrap
    }

    FontDialog {
      id: fontDialogId
      title: "Choose a font"
      currentFont: Qt.font(
        {
          family: "Arial",
          pointSize: 24,
          weight: Font.Normal
        }
      )
      onAccepted: function() {
        print("Chosen font: " + selectedFont)
        textId.font = selectedFont
      }
      onRejected: function() {
        print("User rejected the dialog")
      }
    }
  }
}
