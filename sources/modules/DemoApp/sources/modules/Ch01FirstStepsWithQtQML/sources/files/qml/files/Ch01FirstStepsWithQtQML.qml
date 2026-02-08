pragma ComponentBehavior: Bound
import QtQuick
import S01Intro

Rectangle {
  id: rootRectangle
  width: 500
  height: 500
  color: "transparent"
  border.color: "#666"
  border.width: 1
  visible: true

  Text {
    anchors.centerIn: parent
    text: "Ch01FirstStepsWithQtQML.qml"
    font.pixelSize: 26
    color: "#111"
  }

  S01Intro {}
}
