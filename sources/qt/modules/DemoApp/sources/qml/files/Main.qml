pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Ch01FirstStepsWithQtQML

ApplicationWindow {
  id: rootApplicationWindow
  visible: true

  Rectangle {
    width: 1000
    height: 1000
    color: "transparent"
    border.color: "#666"
    border.width: 1

    Text {
      anchors.centerIn: parent
      text: "Main.qml"
      font.pixelSize: 26
      color: "#111"
    }

    Ch01FirstStepsWithQtQML {}
  }
}
