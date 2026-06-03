pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls

ApplicationWindow {
  id: rootId
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  Rectangle {
    id: rectId
    RandomNumber on width {
      maxValue: 600
    }
    height: 300
    color: "dodgerblue"
    RandomNumber on radius {
      maxValue: 300
    }
  }
}
