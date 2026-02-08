pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  property string textToShow: "Hello"

  Row {
    id: row1
    anchors.centerIn: parent
    spacing: 20
    Rectangle {
      id: redRectId
      width: 50
      height: 50
      color: "red"
      radius: 20

      MouseArea {
        anchors.fill: parent
        onClicked: {
          ApplicationWindow.window.title = "Clicked on the red rectangle";
          rootRectangle.textToShow = "red";
        }
      }
    }

    Rectangle {
      id: greenRectId
      width: 50
      height: 50
      color: "green"
      radius: 20

      MouseArea {
        anchors.fill: parent
        onClicked: {
          ApplicationWindow.window.title = "Clicked on the green rectangle";
          rootRectangle.textToShow = "green";
        }
      }
    }

    Rectangle {
      id: blueRectId
      width: 50
      height: 50
      color: "blue"
      radius: 20

      MouseArea {
        anchors.fill: parent
        onClicked: {
          ApplicationWindow.window.title = "Clicked on the blue rectangle";
          rootRectangle.textToShow = "blue";
        }
      }
    }

    Rectangle {
      id: dodgerblueRectId
      width: 50
      height: 50
      color: "dodgerblue"
      radius: dodgerblueRectId.width / 2

      Text {
        id: dodgerblueRectText
        anchors.centerIn: parent
        text: rootRectangle.textToShow
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          ApplicationWindow.window.title = "Clicked on the dodgerblue circle";
          // Break the binding by assigning a static value
          dodgerblueRectText.text = "broken";
        }
      }
    }
  }
}
