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

      ColorAnimation {
        id: colorAnimationId
        target: containedRectId
        property: "color"
        from: containedRectId.color
        to: "blue"
        duration: 1000
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: function (mouse) {
        colorAnimationId.start();

        print("ContainedRectId x: " + containedRectId.x);
        print("ContainedRectId y: " + containedRectId.y);
      }
    }
  }
}
