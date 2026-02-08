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
    color: "blue"

    Text {
      id: rectTextId
      anchors.centerIn: parent
      text: ""
      color: "white"
    }

    MouseArea {
      id: mouseAreaId
      anchors.fill: parent
    }
  }

  Connections {
    target: mouseAreaId
    function onClicked() {
      rectTextId.text = "Clicked";
    }
    function onDoubleClicked(mouse) {
      rectTextId.text = "Doubleclicked at: " + mouse.x;
    }
  }
}
