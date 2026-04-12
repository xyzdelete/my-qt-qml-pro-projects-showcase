import QtQuick

Item {
  id: notifierId

  property alias rectColor: notifierRectId.color

  width: notifierRectId.width
  height: notifierRectId.height

  // Set up custom property
  property int count: 0

  // required property Receiver target
  // onTargetChanged: {
  //   notify.connect(target.receiveInfo)
  // }

  // Set up the signal
  signal notify(string count)

  Rectangle {
    id: notifierRectId
    width: 200
    height: 200
    color: "red"

    Text {
      id: displayTextId
      anchors.centerIn: parent
      font.pointSize: 20
      text: notifierId.count
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        notifierId.count++;
        notifierId.notify(notifierId.count)
      }
    }
  }
}