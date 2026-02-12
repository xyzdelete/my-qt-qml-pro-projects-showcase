import QtQuick

Window {
  width: 640
  height: 480
  visible: true
  title: qsTr("Hello World")

  Item {
    id: containerItemId
    x: 50
    y: 50
    width: 400
    height: 200

    // #1
    anchors.centerIn: parent

    // #2
    // anchors {
    //   centerIn: parent
    // }

    Rectangle {
      anchors.fill: parent
      color: "dodgerblue"

      // #1
      // border.color: "black"
      // border.width: 5

      // #2
      // border {
      //   color: "black"
      //   width: 5
      // }

      border.color: "black"; border.width: 5
    }

    Rectangle {
      x: 0
      y: 10

      width: 50
      height: 50
      color: "red"
      MouseArea {
        anchors.fill: parent
        onClicked: {

        }
      }
    }

    Rectangle {
      x: 60
      y: 10

      width: 50
      height: 50
      color: "green"
      MouseArea {
        anchors.fill: parent
        onClicked: {

        }
      }
    }

    Rectangle {
      x: 120
      y: 10

      width: 50
      height: 50
      color: "blue"
      MouseArea {
        anchors.fill: parent
        onClicked: {

        }
      }
    }

    Text {
      id: mTextId
      x: 100
      y: 100
      text: "Hello World"
      color: "black"

      // #1
      font.family: "Helvetica"
      font.pointSize: 13
      font.bold: true

      // #2
      // font {
      //   family: "Helvetica"
      //   pointSize: 13
      //   bold: true
      // }

      // #3
      //font.family: "Helvetica"; font.pointSize: 13; font.bold: true
    }
  }
}
