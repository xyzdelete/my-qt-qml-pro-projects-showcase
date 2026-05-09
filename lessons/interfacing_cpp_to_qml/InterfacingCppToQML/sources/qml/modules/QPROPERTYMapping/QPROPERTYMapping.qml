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

  Column {
    spacing: 20
    anchors.fill: parent
    Text {
      id: titleId
      width: 500
      text: Movie === null ? "" : Movie.title
      // text: Movie.title
      font.pointSize: 20
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
      id: mainCharId
      width: 500
      text: Movie === null ? "" : Movie.mainCharacter
      // text: Movie.mainCharacter
      font.pointSize: 20
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter

      TextField {
        id: titleTextFieldId
        width: 300
      }
      Button {
        id: button1
        width: 200
        text: "Change Title"
        onClicked: function () {
          Movie.title = titleTextFieldId.text;
        }
      }
    }
    Row {
      anchors.horizontalCenter: parent.horizontalCenter

      TextField {
        id: mainCharTextFieldId
        width: 300
      }
      Button {
        id: button2
        width: 200
        text: "Change main character"
        onClicked: function () {
          Movie.mainCharacter = mainCharTextFieldId.text;
        }
      }
    }
  }
}
