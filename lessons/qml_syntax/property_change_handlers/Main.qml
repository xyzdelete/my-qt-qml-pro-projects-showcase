import QtQuick

Window {
  id: rootId
  width: 640
  height: 480
  visible: true
  title: qsTr("Property Change Handlers")

  property string name: "Steve" // Custom property

  onNameChanged: {
    print("Name: " + name)
  }
  onTitleChanged: {
    print("New title: " + title)
  }

  Rectangle {
    width: 300
    height: 100
    color: "greenyellow"
    anchors.centerIn: parent

    MouseArea {
      anchors.fill: parent
      onClicked: {
        rootId.name = "Morion"
        rootId.title = "New title"
      }
    }
  }

  Component.onCompleted: {
    print("Before any change - Name: " + name)
  }
}
