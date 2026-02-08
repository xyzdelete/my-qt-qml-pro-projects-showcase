pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Item {
  id: rootId
  width: notifierRectId.width
  height: notifierRectId.height
  property int count: 0
  signal notify(string count)

  property Receiver target: null

  onTargetChanged: function () {
    notify.connect(target.receiveInfo);
  }

  property color rectColor: "black"
  onRectColorChanged: {
    notifierRectId.color = rectColor;
  }

  Rectangle {
    id: notifierRectId
    width: 150
    height: 150
    color: "red"

    Text {
      id: displayTextId
      anchors.centerIn: parent
      font.pointSize: 20
      text: rootId.count
    }

    MouseArea {
      anchors.fill: parent
      onClicked: function () {
        rootId.count++;
        rootId.notify(rootId.count);
      }
    }
  }
}
