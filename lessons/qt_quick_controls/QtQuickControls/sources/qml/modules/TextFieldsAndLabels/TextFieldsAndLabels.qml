import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  Column {
    spacing: 30
    anchors.centerIn: parent

    Row {
      spacing: 30
      anchors.horizontalCenter: parent.horizontalCenter

      Label {
        width: 100
        height: 50
        wrapMode: Label.Wrap
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        text: "First name: "
      }

      TextField {
        id: textFieldId
        width: 200
        height: 50
        placeholderText: "Type in your name"
        onEditingFinished: function() {
          print("Current text: " + text)
        }
      }
    }

    Button {
      text: "Click"
      onClicked: function() {
        print("Text: " + textFieldId.text)
      }
    }
  }
}