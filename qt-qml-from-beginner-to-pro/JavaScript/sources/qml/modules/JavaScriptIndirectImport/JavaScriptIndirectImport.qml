import QtQuick
import "utilities1.js" as Utilities1

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
      text: "Click Me"
      anchors.centerIn: parent
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        print("The ages yield: " + Utilities1.combineAges(33, 17))
        // value = Utilities1.add(33, 17);
      }
    }
  }
}