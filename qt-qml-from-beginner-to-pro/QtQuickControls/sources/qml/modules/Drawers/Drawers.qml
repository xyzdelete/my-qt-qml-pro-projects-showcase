import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

ApplicationWindow {
  id: rootId
  width: 360
  height: 520
  visible: true
  Material.foreground: "black"

  header: ToolBar {
    height: 50
    background: Rectangle {
      color: "mintcream"
    }

    RowLayout {
      spacing: 20
      anchors.fill: parent

      ToolButton {
        background: Rectangle {
          color: "mintcream"
        }

        icon.source: "images/drawer.png"

        onClicked: function() {
          drawerId.open()
        }
      }

      Label {
        id: titleLabelId
        text: "Drawer App"
        font.pointSize: 20
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        Layout.fillWidth: true
      }
    }
  }

  Drawer {
    id: drawerId
    width: Math.min(rootId.width, rootId.height) * (2 / 3)
    height: rootId.height
    interactive: true

    ColumnLayout {
      spacing: 0
      width: parent.width

      Button {
        height: 50
        text: "Item1"
        font.pointSize: 20
        background: Rectangle {
          color: "beige"
        }
        Layout.fillWidth: true
        onClicked: function() {
          print("Clicked on Item1")
          contentRectId.color = "red"
          drawerId.close()
        }
      }
      Button {
        height: 50
        text: "Item2"
        font.pointSize: 20
        background: Rectangle {
          color: "yellowgreen"
        }
        Layout.fillWidth: true
        onClicked: function() {
          print("Clicked on Item2")
          contentRectId.color = "green"
          drawerId.close()
        }
      }
      Button {
        height: 50
        text: "Item3"
        font.pointSize: 20
        background: Rectangle {
          color: "dodgerblue"
        }
        Layout.fillWidth: true
        onClicked: function() {
          print("Clicked on Item3")
          contentRectId.color = "blue"
          drawerId.close()
        }
      }
    }
  }

  Rectangle {
    id: contentRectId
    anchors.fill: parent
    color: "gray"
  }
}
