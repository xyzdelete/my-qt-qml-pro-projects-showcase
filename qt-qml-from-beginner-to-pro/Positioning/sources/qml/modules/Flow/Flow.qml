import QtQuick

Item {
  width: parent.width
  height: parent.height
  anchors.fill: parent

  Flow {
    anchors.fill: parent
    anchors.margins: 4
    spacing: 20

    flow: Flow.TopToBottom
    // layoutDirection: Qt.RightToLeft

    Rectangle {
      id: topLeftRectId
      width: 70
      height: width
      color: "green"
      Text {
        anchors.centerIn: parent
        text: "1"
        font.pointSize: 20
      }
    }
    Rectangle {
      id: topCenterRectId
      width: 100
      height: width
      color: "red"
      Text {
        anchors.centerIn: parent
        text: "2"
        font.pointSize: 20
      }
    }
    Rectangle {
      id: topRightRectId
      width: 100
      height: width
      color: "blue"
      Text {
        anchors.centerIn: parent
        text: "3"
        font.pointSize: 20
      }
    }
    Rectangle {
      id: centerLeftRectId
      width: 100
      height: width
      color: "beige"
      Text {
        anchors.centerIn: parent
        text: "4"
        font.pointSize: 20
      }
    }
    Rectangle {
      id: centerCenterRectId
      width: 100
      height: width
      color: "pink"
      Text {
        anchors.centerIn: parent
        text: "5"
        font.pointSize: 20
      }
    }
    Rectangle {
      id: centerRightRectId
      width: 100
      height: width
      color: "yellow"
      Text {
        anchors.centerIn: parent
        text: "6"
        font.pointSize: 20
      }
    }
    Rectangle {
      id: bottomLeftRectId
      width: 100
      height: width
      color: "magenta"
      Text {
        anchors.centerIn: parent
        text: "7"
        font.pointSize: 20
      }
    }
    Rectangle {
      id: bottomCenterRectId
      width: 100
      height: width
      color: "yellowgreen"
      Text {
        anchors.centerIn: parent
        text: "8"
        font.pointSize: 20
      }
    }
    Rectangle {
      id: bottomRightRectId
      width: 100
      height: width
      color: "dodgerblue"
      Text {
        anchors.centerIn: parent
        text: "9"
        font.pointSize: 20
      }
    }
  }
}