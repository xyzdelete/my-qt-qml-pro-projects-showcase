import QtQuick

Window {
  width: 640
  height: 480
  visible: true
  title: qsTr("QML Syntax Demo")
  property string textToShow: "hello"

  Row {
    anchors.centerIn: parent
    spacing: 20
    Rectangle {
      id: redRectId
      width: 100
      height: 100
      color: "red"
      border.color: "black"
      border.width: 5
      radius: 15
      MouseArea {
        anchors.fill: parent
        onClicked: {
          console.log("Clicked on the red rectangle")
          textToShow = "red"
        }
      }
    }
    Rectangle {
      id: blueRectId
      width: 100
      height: 100
      color: "blue"
      border.color: "black"
      border.width: 5
      radius: 15
      MouseArea {
        anchors.fill: parent
        onClicked: {
          console.log("Clicked on the blue rectangle")
          textToShow = "blue"
        }
      }
    }
    Rectangle {
      id: greenRectId
      width: 100
      height: 100
      color: "green"
      border.color: "black"
      border.width: 5
      radius: 15
      MouseArea {
        anchors.fill: parent
        onClicked: {
          console.log("Clicked on the green rectangle")
          textToShow = "green"
        }
      }
    }
    Rectangle {
      id: circleId
      width: 100
      height: 100
      color: "dodgerblue"
      border.color: "black"
      border.width: 5
      radius: 50
      Text {
        id: textId
        anchors.centerIn: parent
        text: textToShow
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          console.log("Clicked on the dodgerblue circle")
          textId.text = "broken"
        }
      }
    }
  }

}
