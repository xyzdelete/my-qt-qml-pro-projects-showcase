import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  ColumnLayout {
    anchors.fill: parent

    spacing: 40
    Label {
      anchors.fill: parent
      wrapMode: Label.Wrap
      horizontalAlignment: Qt.AlignHCenter
      text: "A knob used to let the user choose a value from a range"
      font.pointSize: 15
    }

    Dial {
      anchors.horizontalCenter: parent.horizontalCenter
      from: 1
      to: 100
      value: 50
      wrap: true

      onValueChanged: {
        print("Current value: " + value)
      }
    }
  }
}