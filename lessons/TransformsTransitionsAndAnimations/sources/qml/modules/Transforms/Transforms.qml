pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels

ApplicationWindow {
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  ClickableRect {
    id: rect1Id
    width: 100
    height: width
    x: 50
    y: 100
    color: "red"
    onClicked: function () {
      // Translation on x
      x += 20;
    }
  }
  ClickableRect {
    id: rect2Id
    width: 100
    height: width
    transformOrigin: Item.TopRight
    x: 250
    y: 100
    color: "green"
    onClicked: function () {
      // Rotation
      rotation += 15;
    }
  }
  ClickableRect {
    id: rect3Id
    width: 100
    height: width
    transformOrigin: Item.BottomLeft
    x: 450
    y: 100
    color: "blue"
    onClicked: function () {
      // Scale
      scale += 0.05;

      // Rotation
      rotation += 20;
    }
  }
}
