import QtQuick

Item {
  Rectangle {
    id: rectId
    width: 300
    height: 300
    color: "dodgerblue"

    // Set up the signal
    signal greet(string message)

    // Set up the custom handler function
    function respond_your_way(message) {
      print("Custom response: " + message)
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        print("Clicked")
        rectId.greet("Hello World!")
      }
    }
  }

  Component.onCompleted: {
    // Connecting the signal to the handler (slot)
    rectId.greet.connect(rectId.respond_your_way)
  }
}