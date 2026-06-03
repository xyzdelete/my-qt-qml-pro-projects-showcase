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

  StairChart {}
}
