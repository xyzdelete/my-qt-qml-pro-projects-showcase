import QtQuick

Item {
  Rectangle {
    id: rectId
    width: 300
    height: 300
    color: "dodgerblue"

    signal greet(string message)

    onGreet: function (message) {
      print("Greeting with message: " + message)
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        rectId.greet("Hello world!")
      }
    }
  }
}