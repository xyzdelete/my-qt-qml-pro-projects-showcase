import QtQuick

Window {
  width: 640
  height: 480
  visible: true
  title: qsTr("Loading Images through Qt6 Cmake facilities")

  Item {
    id: containerItemId
    x: 100
    y: 50
    width: 600
    height: 500
    anchors {
      centerIn: parent
    }

    Rectangle {
      color: "gray"
      anchors {
        fill: parent
      }
    }

    Image {
      x: 50
      y: 50
      width: 100
      height: 100

      // #1
      // source: "qrc:/images/qt.png"

      // #2
      source: "resources/images/qt.png"
    }
    Component.onCompleted: print(Qt.resolvedUrl("resources/images/qt.png"))
  }
}
