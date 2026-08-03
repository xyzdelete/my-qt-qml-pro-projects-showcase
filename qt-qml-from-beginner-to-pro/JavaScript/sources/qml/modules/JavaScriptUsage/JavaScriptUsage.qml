import QtQuick
import QtQuick.Layouts

Item {
  width: parent.width
  height: parent.height
  anchors.fill: parent
  Rectangle {
    id: containerRectId
    width: 40
    height: getHeight()
    color: x > 300 ? "red" : "green"

    onXChanged: function() {
      print("x: " + x + ", y: " + y)
    }

    //anchors.centerIn: parent

    function getHeight() {
      return width * 2
    }
  }

  MouseArea {
    anchors.fill: parent
    drag.target: containerRectId
    drag.axis: Drag.XAndYAxis
    drag.minimumX: 0
    drag.maximumX: parent.width - containerRectId.width
    drag.minimumY: 0
    drag.maximumY: parent.height - containerRectId.height
  }
}