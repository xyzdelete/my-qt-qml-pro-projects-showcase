pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  Item {
    id: containerItemId
    x: 50
    y: 100
    width: 200
    height: 200

    Rectangle {
      anchors.fill: parent
      color: "beige"
      // border.color: "black"
      // border.width: 5

      border {
        color: "black"
        width: 5
      }
    }

    Rectangle {
      x: 0
      y: 20
      width: 50
      height: 50
      color: "red"
    }

    Rectangle {
      x: 70
      y: 20
      width: 50
      height: 50
      color: "green"
    }

    Text {
      id: mTextId
      x: 50
      y: 100
      color: "red"
      text: "Hello Wrold!"
      font {
        family: "Iosevka Custom"
        pointSize: 13
        bold: true
      }
    }
  }
}
