pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls

ApplicationWindow {
  id: root
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  Logo {
    id: logo1Id
    text: "Learn Qt"
    bgColor: "dodgerblue"
    textColor: "red"
  }

  Logo {
    id: logo2Id
    anchors.top: logo1Id.bottom
    anchors.topMargin: 20
    text: "Go Fluid"
    bgColor: "beige"
    textColor: "black"
    topic: Logo.QTQUICK
  }
}
