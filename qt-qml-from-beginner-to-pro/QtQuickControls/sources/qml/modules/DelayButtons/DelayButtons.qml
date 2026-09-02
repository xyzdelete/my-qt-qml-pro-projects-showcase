import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  ColumnLayout {
    anchors.fill: parent
    Label {
      Layout.fillWidth: true
      text: "Delayed button."
      wrapMode: Label.Wrap
      font.pointSize: 15
    }

    DelayButton {
      property bool activated: false
      text: "DelayButton"
      Layout.fillWidth: true
      delay: 1000

      onPressed: {
        if(activated) {
          print("Button is clicked. Carrying out the task")
          activated = false
        }
      }

      onActivated: {
        print("Button activated")
        activated = true
      }

      onProgressChanged: {
        print(progress)
      }
    }
  }
}