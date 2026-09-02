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
  readonly property int animationDuration: 500
  property bool going_down: true
  function animateCircle() {
    if (going_down === true) {
      // Go down
      xAnimationId.from = 0;
      xAnimationId.to = rootId.width - circleId.width;
      yAnimationId.from = 0;
      yAnimationId.to = rootId.height - circleId.height;
      going_down = false;
    } else {
      // Go up
      xAnimationId.from = rootId.width - circleId.width;
      xAnimationId.to = 0;
      yAnimationId.from = rootId.height - circleId.height;
      yAnimationId.to = 0;
      going_down = true;
    }
    groupedAnimationId.start();
  }

  Rectangle {
    id: containerRectId
    anchors.fill: parent
    color: "grey"

    Rectangle {
      id: circleId
      width: 100
      height: 100
      color: "yellowgreen"
      radius: 70

      // SequentialAnimation {
      ParallelAnimation {
        id: groupedAnimationId

        // Animate x
        NumberAnimation {
          id: xAnimationId
          target: circleId
          property: "x"
          duration: rootId.animationDuration
        }

        // Animate y
        NumberAnimation {
          id: yAnimationId
          target: circleId
          property: "y"
          duration: rootId.animationDuration
        }
      }
    }
    MouseArea {
      anchors.fill: parent
      onClicked: function (mouse) {
        rootId.animateCircle();
      }
    }
  }
}
