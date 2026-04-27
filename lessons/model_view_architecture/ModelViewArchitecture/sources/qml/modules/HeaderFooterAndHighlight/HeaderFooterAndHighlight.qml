import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Dialogs

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  ListView {
    id: listViewId
    anchors.fill: parent
    header: headerId
    footer: Rectangle {
      width: rootId.width
      height: 50
      color: "dodgerblue"
    }

    highlight: Rectangle {
      width: rootId.width
      color: "white"
      radius: 15
      border.color: "yellowgreen"
      opacity: 0.1
      z: 3
    }

    model: [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ]
    // delegate: delegateId
    delegate: Rectangle {
      id: rectangleId
      width: parent.width
      height: 50
      color: "dodgerblue"
      border.color: "black"
      radius: 15
      Text {
        id: textId
        anchors.centerIn: parent
        font.pointSize: 20
        text: modelData
      }

      MouseArea {
        anchors.fill: parent
        onClicked: function() {
          print("Clicked on" + modelData)
          listViewId.currentIndex = index
        }
      }
    }
  }

  Component {
    id: headerId
    Rectangle {
      id: headerRectId
      width: parent.width
      height: 50
      color: "yellowgreen"
      border {
        color: "#9EDDF2"
        width: 2
      }

      Text {
        anchors.centerIn: parent
        text: "Months"
        font.pointSize: 20
      }
    }
  }
}
