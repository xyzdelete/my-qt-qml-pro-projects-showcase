pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"
  property bool running: false

  Rectangle {
    id: containerRectId
    anchors.fill: parent
    color: "beige"

    Rectangle {
      id: containedRectId
      width: 100
      height: 100
      color: "dodgerblue"
      x: 50
      y: 50

      PropertyAnimation on x {
        from: 50
        to: 530
        duration: 2000
        running: rootId.running
      }
      PropertyAnimation on y {
        from: 50
        to: 300
        duration: 2000
        running: rootId.running
      }
      RotationAnimation on rotation {
        from: 50
        to: 600
        duration: 2000
        running: rootId.running
      }
    }

    MouseArea {
      anchors.fill: parent
      onPressed: function () {
        rootId.running = true;
      }
      onReleased: function () {
        rootId.running = false;
      }
    }
  }
}
