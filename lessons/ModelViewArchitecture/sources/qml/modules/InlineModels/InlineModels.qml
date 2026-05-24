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
    anchors.fill: parent
    id: listViewId
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
        }
      }
    }
  }
}
