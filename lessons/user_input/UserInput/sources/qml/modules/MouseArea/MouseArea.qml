import QtQuick
import QtQuick.Layouts

Item {
  width: parent.width
  Rectangle {
    id: containerRectId
    width: parent.width
    height: 200
    color: "beige"

    Rectangle {
      id: movingRectId
      width: 50
      // Property binding
      height: width
      color: "blue"
    }

    MouseArea {
      anchors.fill: parent
      onClicked: function(mouse) {
        print(mouse.x)
        movingRectId.x = mouse.x
      }

      onWheel: function(wheel) {
        print("x: " + wheel.x + ", y: " + wheel.y + ", angleData: " + wheel.angleDelta)
      }

      hoverEnabled: true
      onHoveredChanged: {
        if (containsMouse) {
          containerRectId.color = "red"
        } else {
          containerRectId.color = "green"
        }
      }
    }
  }

  Rectangle {
    id: dragContainerId
    width: parent.width
    height: 200
    color: "lightblue"
    anchors.topMargin: 50
    anchors.top: containerRectId.bottom
    
    Rectangle {
      id: draggableRect
      width: 50
      height: width
      color: "blue"

      onXChanged: {
        print("The x position is: " + x)
      }
    }

    MouseArea {
      anchors.fill: parent
      drag.target: draggableRect
      drag.axis: Drag.XAxis
      drag.minimumX: 0
      drag.maximumX: dragContainerId.width - draggableRect.width
    }
  }
}