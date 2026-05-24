import QtQuick
import QtQuick.Layouts

Item {
  width: parent.width
  anchors.centerIn: parent
  Rectangle {
    id: containerRectId
    anchors.centerIn: parent
    width: 300
    height: 50
    color: "blue"
    // This is important if you want to handle key events
    focus: true

    // Going through specific signals
    // Keys.onDigit5Pressed: function(event) {

    //   if (event.modifiers === Qt.ControlModifier) {
    //     print("Specific signal: Pressed key 5 with Ctrl")
    //   } else {
    //     print("Specific signal: Pressed key 5")
    //   }

    //   // Set to false to forward the event to other handlers
    //   event.accepted = true
    // }

    // Going through the general signal
    Keys.onPressed: function(event) {
      if ((event.key === Qt.Key_5) && event.modifiers & Qt.ControlModifier) {
        print("General signal: Pressed key 5 with Ctrl")
      } else if (event.key === Qt.Key_5) {
        print("General signal: Pressed key 5")
      }
    }

    Keys.onReleased: function(event) {
      switch (event.key) {
      case Qt.Key_5:
        print("Key_5 released")
        break;
      case Qt.Key_M:
        print(event.text + " Released");
        break;
      }
    }
  }
}