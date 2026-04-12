import QtQuick

Item {
  Rectangle {
    id: rectId
    width: 200
    height: 200
    color: "dodgerblue"

    MouseArea {
      id: mouseAreaId
      anchors.fill: parent
    }
  }

  Connections {
    // The source of the signal
    target: mouseAreaId
    function onClicked() {
      print("Clicked on the mouse area")
    }

    function onDoubleClicked(mouse) {
      print("Double clicked at: " + mouse.x)
    }
  }
}