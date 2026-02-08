pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  property string firstName: "Bob"

  onFirstNameChanged: {
    ApplicationWindow.window.title = "The firstname changed to: " + firstName;
  }

  Rectangle {
    id: rectId
    width: 300
    height: 100
    color: "greenyellow"
    anchors.centerIn: parent

    MouseArea {
      anchors.fill: parent
      onClicked: {
        rootRectangle.firstName = "John";
        rectId.height = rectId.height + 50;
      }
    }

    onHeightChanged: {
      ApplicationWindow.window.title = "The rectangle height changed to: " + rectId.height;
    }
  }

  Component.onCompleted: {
    ApplicationWindow.window.title = "The firstname is: " + rootRectangle.firstName;
  }
}
