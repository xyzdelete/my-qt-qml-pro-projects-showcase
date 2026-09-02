import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  Column {
    anchors.fill: parent

    spacing: 20

    Button {
      text: "Start"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: function() {
        progressBarId1.value = 75
      }
    }

    Dial {
      id: dialId
      from: 1
      to: 100
      value: 40
      anchors.horizontalCenter: parent.horizontalCenter
      onValueChanged: function() {
        progressBarId.value = value
      }
    }

    ProgressBar {
      id: progressBarId
      from: 1
      to: 100
      value: 40
      anchors.horizontalCenter: parent.horizontalCenter
      onValueChanged: function() {
        print("Current value: " + visualPosition)
      }
    }

    ProgressBar {
      id: progressBarId1
      indeterminate: true
      from: 1
      to: 100
      value: 40
      anchors.horizontalCenter: parent.horizontalCenter
    }
  }
}