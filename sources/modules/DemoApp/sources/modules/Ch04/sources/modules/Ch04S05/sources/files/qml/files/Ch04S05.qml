pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  Rectangle {
    id: rectId
    width: 200
    height: 200
    color: "green"

    Text {
      id: rectTextId
      anchors.centerIn: parent
      text: ""
      color: "white"
    }

    Component.onCompleted: function () {
      rectTextId.text = "Finished setting up the rectangle";
    }
  }
}
