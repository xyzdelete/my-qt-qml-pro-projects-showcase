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
      text: "Choose a folder"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: function() {
        folderDialogId.open()
      }
    }

    Text {
      id: textId
      text: "User has not chosen yet."
      wrapMode: Text.Wrap
    }

    FolderDialog {
      id: folderDialogId
      title: "Choose a folder"
      currentFolder: folderDialogId.currentFolder
      onAccepted: function() {
        print("Chosen folder: " + currentFolder)
        textId.text = currentFolder
      }
      onRejected: function() {
        print("User rejected the dialog")
      }
    }
  }
}
