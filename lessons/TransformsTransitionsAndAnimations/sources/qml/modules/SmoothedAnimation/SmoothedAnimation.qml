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

    // Rectangle {
    //   id: containedRectId
    //   width: 100
    //   height: 100
    //   color: "dodgerblue"
    //   x: 50
    //   y: 50
    //   SmoothedAnimation {
    //     id: smoothedAnimationId
    //     target: containedRectId
    //     property: "x"
    //     duration: 2000
    //   }
    // }

    // MouseArea {
    //   anchors.fill: parent
    //   onClicked: function (mouse) {
    //     smoothedAnimationId.from = containedRectId.x;
    //     smoothedAnimationId.to = mouse.x;
    //     smoothedAnimationId.start();
    //     print("ContainedRectId x: " + containedRectId.x);
    //   }
    // }

    Rectangle {
      width: 60
      height: 60
      x: rect1.x - 5
      y: rect1.y - 5
      color: "green"

      Behavior on x {
        SmoothedAnimation {
          velocity: 200
        }
      }
      Behavior on y {
        SmoothedAnimation {
          velocity: 200
        }
      }
    }

    Rectangle {
      id: rect1
      width: 50
      height: 50
      color: "red"
    }

    focus: true
    Keys.onRightPressed: rect1.x = rect1.x + 100
    Keys.onLeftPressed: rect1.x = rect1.x - 100
    Keys.onUpPressed: rect1.y = rect1.y - 100
    Keys.onDownPressed: rect1.y = rect1.y + 100
  }
}
