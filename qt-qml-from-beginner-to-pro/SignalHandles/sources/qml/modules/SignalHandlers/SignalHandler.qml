import QtQuick

Item {
  Rectangle {
    id: rectId
    width: 150
    height: 150
    color: "red"

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true

      // clicked is the signal
      // onClicked is the handler
      onClicked: {
        print("Clicked on the rectangle")
      }

      onDoubleClicked: {
        print("Double clicked on the rectangle")
      }

      onEntered: {
        print("You are in!")
      }

      onExited: {
        print("You are out!")
      }

      onWheel: function(wheel) {
        print("Wheel: " + wheel.x)
      }

      onReleased: function(mouse) {
        print("Released at x: " + mouse.x + ", y: " + mouse.y)
      }

      onPressAndHold: function(mouse) {
        print("Was held: " + mouse.wasHeld)
      }

      onPositionChanged: function(mouse) {
        print("Position changed, x: " + mouse.x + ", y: " + mouse.y)
      }
    }
  }
}
