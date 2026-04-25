import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  Column {
    anchors.fill: parent
    spacing: 20

    Switch {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "WiFi"
      checked: true
      onCheckedChanged: function() {
        if (checked) {
          print("WiFi switch is turned ON")
        }
        else {
          print("WiFi switch is turned OFF")
        }
      }
    }

    Switch {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Bluetooth"
    }

    Switch {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "NFC"
      enabled: false
    }
  }
}