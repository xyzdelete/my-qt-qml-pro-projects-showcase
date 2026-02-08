pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Item {
  id: rootId
  property alias buttonText: buttonTextId.text

  width: containerRectId.width
  height: containerRectId.height

  signal buttonClicked

  Rectangle {
    id: containerRectId
    color: "red"
    border {
      color: "blue"
      width: 3
    }

    width: buttonTextId.implicitWidth + 20
    height: buttonTextId.implicitHeight + 20

    Text {
      id: buttonTextId
      text: "Button"
      anchors.centerIn: parent
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        rootId.buttonClicked();
      }
    }
  }
}
