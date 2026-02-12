import QtQuick

Window {
  width: 640
  height: 480
  visible: true
  title: qsTr("Hello World")

  Item {
    id: containerItemId
    x: 100
    y: 50
    width: 600
    height: 500
    anchors {
      centerIn: parent
    }

    Image {
      x: 10
      y: 50
      width: 100
      height: 100

      // #1 Loading from working directory
      source: "file:qt.png"
    }

    Image {
      x: 200
      y: 50
      width: 100
      height: 100

      // #2 Loading from a resource file
      source: "qrc:/images/qt.png"
    }

    // Image {
    //   x: 300
    //   y: 50
    //   width: 100
    //   height: 100

    //   // #3 Loading from a path
    //   source: "file:///C:/images/qt.png"
    // }

    Image {
      x: 400
      y: 50
      width: 100
      height: 100

      // #4 Loading from a url
      source: "https://www.learnqt.guide/assets/blog/image/LearnQt.png"
    }
  }
}
