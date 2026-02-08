pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1
  Column {
    MButton {
      id: button1
      buttonText: "Button1"
      onButtonClicked: {
        ApplicationWindow.window.title = "Clicked on " + buttonText;
      }
    }
    MButton {
      id: button2
      buttonText: "Button2"
      onButtonClicked: {
        ApplicationWindow.window.title = "Clicked on " + buttonText;
      }
    }
  }
}
