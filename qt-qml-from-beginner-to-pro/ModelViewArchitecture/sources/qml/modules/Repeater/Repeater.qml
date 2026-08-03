pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  // Column {
  //   Repeater {
  //     model: 3
  //     delegate: Rectangle {
  //       width: 100; height: 40
  //       border.width: 1
  //       color: "yellow"
  //     }
  //   }
  // }

  // Column {
  //   spacing: 20
  //   Repeater {
  //     // model: ["One", "Two", "Three"]
  //     model: 100
  //     delegate: CheckBox {
  //       required property var modelData
  //       text: modelData
  //     }
  //   }
  // }

  Flickable {
    contentHeight: columnId.implicitHeight
    anchors.fill: parent

    Column {
      id: columnId
      anchors.fill: parent
      spacing: 2

      Repeater {
        model: ["Jan", "Feb", "March"]
        delegate: Rectangle {
          id: rectId
          required property var modelData
          width: parent.width
          height: 50
          color: "dodgerblue"

          Text {
            anchors.centerIn: parent
            text: rectId.modelData
            font.pointSize: 20
          }

          MouseArea {
            anchors.fill: parent
            onClicked: function() {
              print("Clicked on " + rectId.modelData)
            }
          }
        }
      }
    }
  }
}
