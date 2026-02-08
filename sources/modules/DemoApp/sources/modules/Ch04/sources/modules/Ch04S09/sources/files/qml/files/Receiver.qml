pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Item {
  property alias rectColor: receiverRectId.color
  width: receiverRectId.width
  height: receiverRectId.height

  function receiveInfo(count) {
    receiverDisplayTextId.text = count;
    ApplicationWindow.window.title = "Receiver received number: " + count;
  }

  Rectangle {
    id: receiverRectId
    width: 150
    height: 150
    color: "blue"

    Text {
      id: receiverDisplayTextId
      anchors.centerIn: parent
      font.pointSize: 20
      text: "0"
      color: "white"
    }
  }
}
