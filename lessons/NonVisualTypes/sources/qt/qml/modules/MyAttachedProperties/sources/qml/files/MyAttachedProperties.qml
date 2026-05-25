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

  Person {
    name: "Johnson"
    age: 20

    MyTimer.running: false
    MyTimer.interval: 1000
    MyTimer.onTimerOut: function () {
      console.log("Timeout for person object");
    }
  }

  Rectangle {
    id: rectId
    width: 200
    height: 200
    color: "lightgray"

    MyTimer.running: true
    MyTimer.interval: 500
    MyTimer.onTimerOut: function () {
      console.log("Timer out for rect");
    }
  }
}
