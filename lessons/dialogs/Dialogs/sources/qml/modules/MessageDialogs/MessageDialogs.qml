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
      text: "Press me"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: function() {
        messageDialogId.open()
      }
    }


    MessageDialog {
      id: messageDialogId
      title: "Message"
      text: "Hello World!"
      buttons: MessageDialog.Ok | MessageDialog.Cancel
      onAccepted: function() {
        print("Dialog accepted")
      }
      onRejected: function() {
        print("User rejected the dialog")
      }
    }
  }
}
