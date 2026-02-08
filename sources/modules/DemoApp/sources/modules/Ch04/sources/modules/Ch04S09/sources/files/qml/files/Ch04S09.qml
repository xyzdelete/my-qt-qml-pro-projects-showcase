pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  Sender {
    id: notifierId
    rectColor: "yellowgreen"
    target: receiverId
  }

  Receiver {
    id: receiverId
    rectColor: "dodgerblue"
    anchors.right: parent.right
  }

  // Component.onCompleted: function () {
  //   notifierId.notify.connect(receiverId.receiveInfo);
  // }
}
