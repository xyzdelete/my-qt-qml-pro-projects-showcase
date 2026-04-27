pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material

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
    delegate: delegateId
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

  Component {
    id: delegateId
    Rectangle {
      required property var modelData
      required property int index
      id: rectangleId
      width: parent.width
      height: 50
      color: "gray"
      border.color: "black"
      radius: 15
      Text {
        id: textId
        anchors.centerIn: parent
        font.pointSize: 20
        text: rectangleId.modelData
      }

      MouseArea {
        anchors.fill: parent
        onClicked: function() {
          print("Clicked on " + rectangleId.modelData + " at index " + rectangleId.index)
          listViewId.currentIndex = rectangleId.index
        }
      }
    }
  }
}
