pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
  id: rootId
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  ErrorLevel {}

  Component.onCompleted: function () {
    console.log(ErrorLevel.MESSAGE);
  }
}
