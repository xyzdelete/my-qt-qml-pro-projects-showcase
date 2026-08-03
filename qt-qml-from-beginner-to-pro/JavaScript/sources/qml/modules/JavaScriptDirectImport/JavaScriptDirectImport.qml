import QtQuick
import "utilities.js" as Utilities1

Item {
  width: parent.width
  height: parent.height
  anchors.fill: parent

  Rectangle {
    width: 300
    height: 100
    color: "yellowgreen"
    anchors.centerIn: parent

    Text {
      text: "Click me"
      anchors.centerIn: parent
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        Utilities1.greeting()
      }
    }
  }
}