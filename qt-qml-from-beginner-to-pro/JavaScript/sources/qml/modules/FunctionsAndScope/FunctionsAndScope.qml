import QtQuick

Item {
  width: parent.width
  height: parent.height
  anchors.fill: parent

  function min(a, b): real {
    return Math.min(a, b)
  }

  Rectangle {
    id: mRectId
    width: min(500, 400)
    height: 100
    anchors.centerIn: parent
    color: "blue"

    function sayMessage() {
      print("Hello there")
    }

    MouseArea {
      anchors.fill: parent
      onClicked: function() {
        print("mRectId.color: " + mRectId.color)
        print("color: " + color)
        print("mRectId.height: " + mRectId.height)
        print("height: " + height)
        mRectId.sayMessage()
      }
    }
  }

  Component.onCompleted: {
    print("The minimum is " + min(1000, 200))
    mRectId.sayMessage()
  }
}