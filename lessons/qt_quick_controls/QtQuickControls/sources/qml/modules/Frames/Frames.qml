import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent
  Frame
  {
    anchors.centerIn: parent
    ColumnLayout {
      anchors.fill: parent
      Button {
        text: "Button1"
      }
      Button {
        text: "Button2"
      }
      Button {
        text: "Button3"
      }
    }
  }
}