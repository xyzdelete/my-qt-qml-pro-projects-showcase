import QtQuick
import QtQuick.Layouts

FocusScope {
  property alias color: containerRectId.color
  width: containerRectId.width
  height: containerRectId.height
  Rectangle {
    id: containerRectId
    width: 300
    height: 50
    color: "lightgray"
    focus: true

    Text {
      id: textId
      anchors.centerIn: parent
      text: "Default"
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_1) {
            print("Pressed on Key_1")
            textId.text = "Pressed on Key_1"
        } else if (event.key === Qt.Key_2) {
            print("Pressed on Key_2")
            textId.text = "Pressed on Key_2"
        } else {
            print("Pressed on another key: " + event.key)
            textId.text = "Pressed on another key"
        }
    }
  }
}