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
    width: 300
    height: 300
    color: "dodgerblue"

    signal greet(string message)

    onGreet: function (message) {
      ApplicationWindow.window.title = "Greeting with message: " + message;
    }

    MouseArea {
      anchors.fill: parent
      onClicked: function () {
        rectId.greet("The sky is blue");
      }
    }
  }
}
