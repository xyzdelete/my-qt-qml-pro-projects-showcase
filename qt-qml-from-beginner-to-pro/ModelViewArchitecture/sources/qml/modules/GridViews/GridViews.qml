pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  ListModel {
    id: listModelId

    ListElement {
      mNumber: "1"
      mColor: "red"
    }
    ListElement {
      mNumber: "2"
      mColor: "green"
    }
    ListElement {
      mNumber: "3"
      mColor: "beige"
    }
    ListElement {
      mNumber: "4"
      mColor: "yellowgreen"
    }
    ListElement {
      mNumber: "5"
      mColor: "dodgerblue"
    }
    ListElement {
      mNumber: "6"
      mColor: "lightyellow"
    }
    ListElement {
      mNumber: "7"
      mColor: "pink"
    }
    ListElement {
      mNumber: "8"
      mColor: "magenta"
    }
    ListElement {
      mNumber: "9"
      mColor: "silver"
    }
  }

  GridView {
    id: gridViewId
    anchors.fill: parent
    model: listModelId
    delegate: delegateId
    flow: GridView.FlowTopToBottom
    layoutDirection: Qt.RightToLeft
  }

  Component {
    id: delegateId
    Rectangle {
      required property var mColor
      required property var mNumber
      id: rectangleId
      width: 100
      height: width
      color: mColor

      Text {
        text: rectangleId.mNumber
        anchors.centerIn: parent
        font.pointSize: 20
      }
    }
  }
}
