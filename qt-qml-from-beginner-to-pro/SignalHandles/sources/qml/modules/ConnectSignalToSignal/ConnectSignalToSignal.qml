import QtQuick

Item {
  Rectangle {
    id: rectId
    width: 300
    height: 300
    color: "dodgerblue"

    // Set up the signal
    signal greet(string message)
    signal forward_greeting(string message)

    // The final handler
    function respond_your_way(message) {
      print("Custom response: " + message)
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        rectId.greet("Hello world!")
      }
    }
  }

  Component.onCompleted: {
    // Connect signal to signal
    rectId.greet.connect(rectId.forward_greeting)

    // Connect to the final handler
    rectId.forward_greeting.connect(rectId.respond_your_way)
  }
}