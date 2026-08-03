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
      // Behavior on x {
      //   SpringAnimation {
      //     spring: 5
      //     damping: 0.2
      //     duration: 3000
      //   }
      // }

      // Behavior on y {
      //   SpringAnimation {
      //     spring: 5
      //     damping: 0.2
      //     duration: 3000
      //   }
      // }

      SpringAnimation {
        id: springAnimationId
        target: containedRectId
        property: "x"
        spring: 5
        damping: 0.2
        duration: 3000
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: function (mouse) {
        // containedRectId.x = mouse.x;
        // containedRectId.y = mouse.y;

        print("ContainedRectId x: " + containedRectId.x);
        print("ContainedRectId y: " + containedRectId.y);

        springAnimationId.stop();
        springAnimationId.from = containedRectId.x;
        springAnimationId.to = mouse.x;
        springAnimationId.start();
      }
    }
  }
}
