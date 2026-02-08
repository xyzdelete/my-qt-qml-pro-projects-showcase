pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
  id: rootRectangle
  width: 250
  height: 250
  color: "transparent"
  border.color: "#888"
  border.width: 1

  Text {
    anchors.centerIn: parent
    text: "S01Intro.qml"
    font.pixelSize: 24
    color: "#222"
  }
}
