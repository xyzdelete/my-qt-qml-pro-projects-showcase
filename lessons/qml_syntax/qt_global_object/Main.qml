import QtQuick

Window {
  width: 640
  height: 480
  visible: true
  title: qsTr("Hello World")

  property var fonts: Qt.fontFamilies()

  Text {
    anchors.centerIn: parent
    font.pointSize: 20
    color: Qt.rgba(1, 0, 0, 1)
    text: Qt.md5("hello, world")
  }

  Rectangle {
    id: clickableRectId
    width: 300
    height: 100
    color: "dodgerblue"
    anchors.bottom: parent.bottom
    MouseArea {
      anchors.fill: parent
      onClicked: {
        //Qt.quit()

        // Loop through the fonts
        for (var i = 0; i < fonts.length; ++i)
        {
          print("[" + i + "]" + fonts[i])
        }

        // Hash a string
        var mText = "Hello world!"
        var mTextHash = Qt.md5(mText)
        print("The hash of the text is: " + mTextHash)

        //Qt.openUrlExternally("https://www.github.com")

        // If PNG is next to the executable
        var exePath = Qt.application.arguments[0]
        print(exePath)
        var marker = "\\qt_global_object"
        print(marker)
        var idx = exePath.indexOf(marker)
        print(idx)
        if (idx !== -1) {
            var basePath = exePath.substring(0, idx + marker.length)
            var imageUrl = "file:///" + basePath.replace(/\\/g, "/") + "/qt.png"
            Qt.openUrlExternally(imageUrl)
        }

        print(Qt.platform.os)
      }
    }
  }
}
