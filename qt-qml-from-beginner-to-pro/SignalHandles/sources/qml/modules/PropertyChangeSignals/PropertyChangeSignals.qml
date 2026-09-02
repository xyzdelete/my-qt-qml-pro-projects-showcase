import QtQuick

Item {
  Rectangle {
    id: rectId
    width: 300
    // Property binding
    height: width + 50
    color: "dodgerblue"

    // Custom property
    property string description: "A rectangle to play with"

    onWidthChanged: {
      print("Width changed to : " + rectId.width)
    }
    onHeightChanged: {
      print("Height changed to : " + rectId.height)
    }

    onColorChanged: {

    }

    onVisibleChanged: {

    }

    onDescriptionChanged: {
      print("Description changed to: " + rectId.description)
    }

    MouseArea {
      anchors.fill: parent

      onClicked: {
        rectId.width += 20
        rectId.description = "New data"
      }
    }
  }
}