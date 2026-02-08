pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  Rectangle {
    id: rect
    width: 300
    height: width
    color: "dodgerblue"

    property string description: "A rectangle to play with"

    onWidthChanged: function () {
      ApplicationWindow.window.title = "Width changed to: " + rect.width;
    }

    onHeightChanged: function () {
      ApplicationWindow.window.title = "Height changed to: " + rect.height;
    }

    onColorChanged: {}
    onVisibleChanged: {}
    onDescriptionChanged: {}

    MouseArea {
      anchors.fill: parent
      onClicked: {
        rect.width = rect.width + 20;
      }
    }
  }
}
