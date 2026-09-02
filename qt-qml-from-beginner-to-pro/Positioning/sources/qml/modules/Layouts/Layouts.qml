import QtQuick
import QtQuick.Layouts

Item {
  width: parent.width
  height: parent.height
  anchors.fill: parent

  GridLayout {
    id: mGridLayoutId
    anchors.fill: parent
    columns: 3
    // layoutDirection: Qt.RightToLeft

    Rectangle {
      id: topLeftRectId
      // width: 70
      // height: width
      color: "green"
      Text {
        anchors.centerIn: parent
        text: "1"
        font.pointSize: 20
      }

      // Layout.alignment: Qt.AlignRight | Qt.AlignBottom
      Layout.fillWidth: true
      Layout.fillHeight: true
      // Layout.maximumWidth: 150
      // Layout.maximumHeight: 150
    }
    Rectangle {
      id: topCenterRectId
      // width: 100
      // height: width
      color: "red"
      Text {
        anchors.centerIn: parent
        text: "2"
        font.pointSize: 20
      }
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.columnSpan: 2
    }
    // Rectangle {
    //   id: topRightRectId
    //   width: 100
    //   height: width
    //   color: "blue"
    //   Text {
    //     anchors.centerIn: parent
    //     text: "3"
    //     font.pointSize: 20
    //   }
    //   Layout.fillWidth: true
    //   Layout.fillHeight: true
    // }
    Rectangle {
      id: centerLeftRectId
      // width: 100
      // height: width
      color: "beige"
      Text {
        anchors.centerIn: parent
        text: "4"
        font.pointSize: 20
      }
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.rowSpan: 2
    }
    Rectangle {
      id: centerCenterRectId
      // width: 100
      // height: width
      color: "pink"
      Text {
        anchors.centerIn: parent
        text: "5"
        font.pointSize: 20
      }
      Layout.fillWidth: true
      Layout.fillHeight: true
    }
    Rectangle {
      id: centerRightRectId
      // width: 100
      // height: width
      color: "yellow"
      Text {
        anchors.centerIn: parent
        text: "6"
        font.pointSize: 20
      }
      Layout.fillWidth: true
      Layout.fillHeight: true
    }
    // Rectangle {
    //   id: bottomLeftRectId
    //   width: 100
    //   height: width
    //   color: "magenta"
    //   Text {
    //     anchors.centerIn: parent
    //     text: "7"
    //     font.pointSize: 20
    //   }
    //   Layout.fillWidth: true
    //   Layout.fillHeight: true
    // }
    Rectangle {
      id: bottomCenterRectId
      // width: 100
      // height: width
      color: "yellowgreen"
      Text {
        anchors.centerIn: parent
        text: "8"
        font.pointSize: 20
      }
      Layout.fillWidth: true
      Layout.fillHeight: true
    }
    Rectangle {
      id: bottomRightRectId
      // width: 100
      // height: width
      color: "dodgerblue"
      Text {
        anchors.centerIn: parent
        text: "9"
        font.pointSize: 20
      }
      Layout.fillWidth: true
      Layout.fillHeight: true
    }
  }
}