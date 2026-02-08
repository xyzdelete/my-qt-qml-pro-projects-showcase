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
    id: rect
    width: 150
    height: 150
    color: "red"

    MouseArea {
      anchors.fill: parent
      onClicked: function (mouse) {
        ApplicationWindow.window.title = mouse.x;
      }
    }
  }
}
