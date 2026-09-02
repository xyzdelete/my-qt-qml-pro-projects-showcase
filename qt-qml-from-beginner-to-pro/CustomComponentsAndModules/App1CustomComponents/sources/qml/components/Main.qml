import QtQuick

Window {
  width: 640
  height: 480
  visible: true
  title: qsTr("Hello World")

  // Row {
  //   spacing: 2

  //   Rectangle { color: "red"; width: 50; height: 50 }
  //   Rectangle { color: "green"; width: 20; height: 50 }
  //   Rectangle { color: "blue"; width: 50; height: 20 }
  // }

  // Rectangle {
  //   id: containerRectId
  //   width: buttonTextId.implicitWidth + 10
  //   height: buttonTextId.implicitHeight + 10
  //   color: "red"
  //   border {
  //     color: "blue"
  //     width: 3
  //   }

  //   Text {
  //     id: buttonTextId
  //     text: "Button"
  //     anchors {
  //       centerIn: parent
  //     }
  //   }

  //   MouseArea {
  //     anchors {
  //       fill: parent
  //     }
  //     onClicked: {
  //       print("Clicked on the button")
  //     }
  //   }
  // }

  Column {
    spacing: 3

    MButton {
      id: buttonId1
      buttonText: "Button 1"
      onButtonClicked: {
        print("Clicked on button 1")
      }
    }
    MButton {
      id: buttonId2
      buttonText: "Button 2"
      onButtonClicked: {
        print("Clicked on button 2")
      }
    }
  }
}
