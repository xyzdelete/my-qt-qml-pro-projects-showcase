pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  Text {
    id: rootText
    text: "Hello World!"
    font.family: "Helvetica"
    font.pointSize: 24
    color: "red"
    anchors.centerIn: parent
  }
}
