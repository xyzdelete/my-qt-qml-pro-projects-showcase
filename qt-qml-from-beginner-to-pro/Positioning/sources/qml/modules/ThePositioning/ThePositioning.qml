import QtQuick

Item {
  width: parent.width
  height: parent.height
  anchors.fill: parent

  Grid {
    columns: 2
    // spacing: 10
    rowSpacing: 10
    columnSpacing: 10

    horizontalItemAlignment: Grid.AlignLeft
    verticalItemAlignment: Grid.AlignVCenter

    LayoutMirroring.enabled: true
    LayoutMirroring.childrenInherit: true

    Rectangle {
      id: topLeftRectId
      width: 60
      height: width
      color: "magenta"
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
      color: "yellowgreen"
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
      color: "dodgerblue"
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
      color: "red"
      Text {
        anchors.centerIn: parent
        text: "4"
        font.pointSize: 20
      }
    }
  }
}