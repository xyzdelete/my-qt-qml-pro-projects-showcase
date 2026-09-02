import QtQuick

Item {
  width: parent.width
  height: parent.height
  Rectangle {
    id: rectId
    width: parent.width
    height: parent.height
    Notifier {
      id: notifierId
      rectColor: "Yellowgreen"
      anchors.left: parent.left
      // onNotify: function (count) {
      //   print("Received: " + count)
      // }
      // target: receiverId
    }
    Receiver {
      id: receiverId
      rectColor: "dodgerblue"
      anchors.right: parent.right
    }
  }

  // Make the connection from notifier to receiver
  Component.onCompleted: {
    notifierId.notify.connect(receiverId.receiveInfo)
  }
}