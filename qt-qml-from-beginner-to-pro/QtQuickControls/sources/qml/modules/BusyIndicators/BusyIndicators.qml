import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  ColumnLayout {
    width: parent.width

    BusyIndicator {
      id: busyIndicatorId
      running: true
      Layout.alignment: Qt.AlignHCenter
    }

    ColumnLayout {
      Button {
        id: button1
        text: "Running"
        Layout.fillWidth: true
        onClicked: {
          busyIndicatorId.running = true
          busyIndicatorId.visible = true
        }
      }
      Button {
        id: button2
        text: "Not running"
        Layout.fillWidth: true
        onClicked: {
          busyIndicatorId.running = false
          busyIndicatorId.visible = false
        }
      }
    }
  }
}