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
    color: "grey"
    readonly property int pendulumAngle: 30
    readonly property int animDuration: 500

    Rectangle {
      id: pendulumId
      width: 20
      height: 200
      color: "black"
      x: (parent.width - width) / 2
      y: 50
      transformOrigin: Item.Top

      Rectangle {
        id: bobId
        width: 50
        height: 50
        color: "red"
        radius: width / 2
        x: (pendulumId.width - width) / 2
        y: pendulumId.height
        transformOrigin: Item.Bottom
        rotation: pendulumId.rotation
      }

      SequentialAnimation {
        loops: Animation.Infinite
        running: true

        NumberAnimation {
          id: rightToLeftAnimationId
          target: pendulumId
          property: "rotation"
          from: -containerRectId.pendulumAngle
          to: containerRectId.pendulumAngle
          duration: containerRectId.animDuration
          easing.type: Easing.InOutQuad
        }
        NumberAnimation {
          id: leftToRightAnimationId
          target: pendulumId
          property: "rotation"
          from: containerRectId.pendulumAngle
          to: -containerRectId.pendulumAngle
          duration: containerRectId.animDuration
          easing.type: Easing.InOutQuad
        }
      }
    }
    MouseArea {
      anchors.fill: parent
      onClicked: function (mouse) {}
    }
  }
}
