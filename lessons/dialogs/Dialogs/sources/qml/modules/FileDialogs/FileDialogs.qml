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
      text: "Choose a file"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: function() {
        fileDialogId.open()
      }
    }

    Text {
      id: textId
      text: "User has not chosen yet."
      wrapMode: Text.Wrap
    }

    FileDialog {
      id: fileDialogId
      title: "Choose a file"
      nameFilters: ["Text files (*.txt)", "HTML files (*.html *.htm)", "Images (*.jpg *.png)"]
      // Allow for selecting multiple files
      fileMode: FileDialog.OpenFiles
      onAccepted: function() {
        print("Chosen file: " + currentFiles)
        textId.text = currentFile
      }
      onRejected: function() {
        print("User rejected the dialog")
      }
    }
  }
}
