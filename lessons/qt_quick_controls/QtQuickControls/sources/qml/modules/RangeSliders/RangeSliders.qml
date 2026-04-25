import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  RangeSlider {
    anchors.centerIn: parent
    from: 1
    to: 100
    first.value: 25
    second.value: 75

    first.onValueChanged: function() {
      print("First value changed to " + first.value)
    }
    second.onValueChanged: function() {
      print("Second value changed to " + second.value)
    }
  }
}