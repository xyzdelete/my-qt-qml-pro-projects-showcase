import QtQuick

Item {
  id: rootId
  property var backgroundColor
  property var startColor
  property var endColor
  property string easingText
  property int animDuration
  property var easingType
  property int containerwidth

  width: containedRectId.width
  height: containedRectId.height

  property int finalX: containerRectId.width - containedRectId.width

  Rectangle {
    id: containerRectId
    width: rootId.containerwidth
    height: 50
    color: rootId.backgroundColor

    Text {
      text: rootId.easingText
      anchors.centerIn: parent
    }

    Rectangle {
      id: containedRectId
      color: rootId.startColor
      width: 50
      height: 50
      border {
        width: 5
        color: "black"
      }
      radius: 10

      NumberAnimation {
        id: numberAnimationId
        target: containedRectId
        property: "x"
        easing.type: rootId.easingType
        to: containerRectId.width - containedRectId.width
        duration: rootId.animDuration
      }

      ColorAnimation {
        id: colorAnimationId
        target: containedRectId
        property: "color"
        from: rootId.startColor
        to: rootId.endColor
        duration: rootId.animDuration
      }
    }

    MouseArea {
      anchors.fill: parent
      property bool toRight: true
      onClicked: function () {
        if (toRight === true) {
          // Move towards the right
          toRight = false;
          // Animate x
          numberAnimationId.to = containerRectId.width - containedRectId.width;
          numberAnimationId.start();
          // Animate the color
          colorAnimationId.from = rootId.startColor;
          colorAnimationId.to = rootId.endColor;
          colorAnimationId.start();
        } else {
          // Move towards the left
          toRight = true;
          // Animate x
          numberAnimationId.to = 0;
          numberAnimationId.start();
          // Animate the color
          colorAnimationId.from = rootId.endColor;
          colorAnimationId.to = rootId.startColor;
          colorAnimationId.start();
        }

        print("ContainedRectId x: " + containedRectId.x);
        print("ContainedRectId y: " + containedRectId.y);
      }
    }
  }
}
