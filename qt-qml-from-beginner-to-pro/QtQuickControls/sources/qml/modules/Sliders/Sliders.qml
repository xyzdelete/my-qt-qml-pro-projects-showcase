import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  Column {
    anchors.fill: parent
    spacing: 20

    Slider {
      id: sliderId
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width

      from: 1
      to: 100
      value: 40
      onValueChanged: function() {
        progressBarId.value = value
      }
    }

    ProgressBar {
      anchors.horizontalCenter: parent.horizontalCenter
      width: sliderId.width
      id: progressBarId
      from: 1
      to: 100
    }
  }
}