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

      PropertyAnimation {
        id: xAnimationId
        target: containedRectId
        property: "x"
        to: 530
        duration: 2000
      }
      PropertyAnimation {
        id: yAnimationId
        target: containedRectId
        property: "y"
        to: 300
        duration: 2000
      }
      RotationAnimation {
        id: rotationAnimationId
        target: containedRectId
        property: "rotation"
        to: 600
        duration: 2000
      }
    }

    MouseArea {
      anchors.fill: parent
      onPressed: function () {
        // Start animation
        xAnimationId.start();
        yAnimationId.start();
        rotationAnimationId.start();
      }
      onReleased: function () {
        // Stop animation
        xAnimationId.stop();
        yAnimationId.stop();
        rotationAnimationId.stop();
      }
    }
  }
}
