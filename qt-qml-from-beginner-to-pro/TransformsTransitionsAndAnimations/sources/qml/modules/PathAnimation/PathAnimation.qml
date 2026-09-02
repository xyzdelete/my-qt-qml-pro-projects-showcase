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
      x: rootId.width / 2 - 50
      y: rootId.height - 50 - 50
      radius: 80

      PathAnimation {
        id: pathAnimationId
        target: containedRectId
        duration: 1000
        anchorPoint: Qt.point(50, 50)
        path: Path {
          // Starting point
          startX: rootId.width / 2
          startY: rootId.height - 50

          // Towards left: Q1
          PathCubic {
            x: 50
            y: rootId.height / 2
            control1X: rootId.width / 2 - rootId.width / 8
            control1Y: rootId.height
            control2X: 0
            control2Y: rootId.height / 2 + rootId.height / 8
          }

          // Towards top: Q2
          PathCubic {
            x: rootId.height / 2
            y: 50
            control1X: 0
            control1Y: (rootId.height / 2 - rootId.height / 8)
            control2X: (rootId.width / 2 - rootId.width / 8)
            control2Y: 0
          }

          // Towards right: Q3
          PathCubic {
            x: rootId.width - 50
            y: rootId.height / 2
            control1X: (rootId.width / 2 + rootId.width / 8)
            control1Y: 0
            control2X: rootId.width
            control2Y: (rootId.height / 2 - rootId.height / 8)
          }

          // Towards bottom: Q4
          PathCubic {
            x: rootId.width / 2
            y: rootId.height - 50
            control1X: rootId.width
            control1Y: (rootId.height / 2 + rootId.height / 8)
            control2X: (rootId.width / 2 + rootId.width / 8)
            control2Y: rootId.height
          }
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: function (mouse) {
        pathAnimationId.start();

        print("ContainedRectId x: " + containedRectId.x);
        print("ContainedRectId y: " + containedRectId.y);
      }
    }
  }
}
