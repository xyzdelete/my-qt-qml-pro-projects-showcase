import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  ColumnLayout {
    anchors.left: parent.left
    anchors.right: parent.right

    Button {
      id: button1
      text: "Button1"
      Layout.fillWidth: true
      onClicked: function() {
        print("Clicked on Button1")
      }
    }
    Button {
      id: button2
      text: "Button2"
      Layout.fillWidth: true
      onClicked: function() {
        print("Clicked on Button2")
      }
    }
  }
}