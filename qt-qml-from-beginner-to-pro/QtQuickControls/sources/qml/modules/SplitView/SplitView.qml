import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  SplitView {
    anchors.fill: parent
    orientation: Qt.Horizontal

    Rectangle {
      id: rect1Id
      color: "lightblue"
      Text {
        text: "View 1"
        anchors.centerIn: parent
      }
      SplitView.preferredWidth: 100
    }
    Rectangle {
      id: rect2Id
      color: "lightgrey"
      Text {
        text: "View 2"
        anchors.centerIn: parent
      }
      SplitView.preferredWidth: 100
      SplitView.minimumWidth: 50
    }
    Rectangle {
      id: rect3Id
      color: "lightgreen"
      Text {
        text: "View 3"
        anchors.centerIn: parent
      }
      SplitView.preferredWidth: 100
    }
  }
}