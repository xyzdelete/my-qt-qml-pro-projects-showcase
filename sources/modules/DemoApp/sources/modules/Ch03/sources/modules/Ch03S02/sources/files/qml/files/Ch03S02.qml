pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  Item {
    id: containerItemId
    x: 50
    y: 50
    width: 300
    height: 300

    Image {
      x: 10
      y: 50
      width: 100
      height: 100

      source: "qrc:/qt/qml/Ch03S02/sources/resources/images/LearnQt.png"
    }

    Image {
      x: 120
      y: 50
      width: 100
      height: 100

      source: "file:///C:/repos/learn-qt/my-qt-qml-pro-projects-showcase/sources/modules/DemoApp/sources/modules/Ch03/sources/modules/Ch03S02/sources/resources/images/LearnQt.png"
    }

    Image {
      x: 10
      y: 160
      width: 100
      height: 100

      source: "https://raw.githubusercontent.com/xyzdelete/my-qt-qml-pro-projects-showcase/a0f4b56c13e8c72d6b90c9adca65a85b750be266/sources/modules/RESTClientApp/sources/resources/assets/icons/base/dark/rounded/RESTClientApp.svg"
    }
  }
}
