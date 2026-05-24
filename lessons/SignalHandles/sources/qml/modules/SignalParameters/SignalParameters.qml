import QtQuick

Item {
  Rectangle {
    id: rectId
    width: 150
    height: 150
    color: "red"

    MouseArea {
      anchors.fill: parent

      // Syntax variation #1
      // Deprecated
      // onClicked: {
      //   print("Position x: " + mouse.x + " ,y: " + mouse.y)
      // }

      // Syntax variation #2
      // onClicked: function(mouse_param) {
      //   print("Position x: " + mouse_param.x + " ,y: " + mouse_param.y)
      // }

      // Syntax variation #3 : Arrow functions
      onClicked: mouse_param => {
        print("Position x: " + mouse_param.x + " ,y: " + mouse_param.y)
      }
    }
  }
}
