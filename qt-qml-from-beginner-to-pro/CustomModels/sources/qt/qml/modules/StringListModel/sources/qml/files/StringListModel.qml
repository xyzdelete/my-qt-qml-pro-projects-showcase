pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls

ApplicationWindow {
  id: rootId
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  ListView {
    id: mListViewId
    anchors.fill: parent

    model: continentModel
    // model: itemList1
    // model: itemList2
    delegate: Rectangle {
      id: delegateId
      required property var modelData
      height: 50
      radius: 10
      color: "dodgerblue"
      border.color: "cyan"
      width: (parent === null ? rootId.width : parent.width) // To avoid property of null errors when
      // ListView is temporarity destroyed
      Text {
        text: delegateId.modelData
        font.pointSize: 20
        anchors.centerIn: parent
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }
  }
}
