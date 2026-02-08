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
      hoverEnabled: true

      onClicked: {
        ApplicationWindow.window.title = "Clicked on the rect";
      }

      onDoubleClicked: {
        ApplicationWindow.window.title = "Double clicked on the rect";
      }

      onEntered: {
        ApplicationWindow.window.title = "You're in!";
      }

      onExited: {
        ApplicationWindow.window.title = "You're out!";
      }

      onWheel: function (wheel) {
        ApplicationWindow.window.title = "Wheel: " + wheel.x;
      }
    }
  }
}
