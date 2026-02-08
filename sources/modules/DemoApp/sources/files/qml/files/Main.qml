pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Ch01
import Ch02
import Ch03
import Ch04

ApplicationWindow {
  id: rootApplicationWindow
  visible: true
  width: 360
  height: 720
  minimumWidth: 320
  minimumHeight: 640
  title: qsTr("DemoApp")

  Rectangle {
    color: "transparent"
    anchors.fill: parent
    border.color: '#ff0000'
    border.width: 1

    // Chapter 1: First Steps with Qt QML
    //Ch01 {}

    // Chapter 2: Dissecting the QML Syntax
    // Ch02 {}

    // Chapter 3: Basic QML Elements
    // Ch03 {}

    // Chapter 4: Signals and Handlers
    Ch04 {}
  }
}
