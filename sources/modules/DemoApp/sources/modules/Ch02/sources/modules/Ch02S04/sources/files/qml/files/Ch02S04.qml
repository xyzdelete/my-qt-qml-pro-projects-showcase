pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  property var fonts: Qt.fontFamilies()

  Rectangle {
    width: 300
    height: 100
    color: "red"
    anchors.centerIn: parent

    MouseArea {
      anchors.fill: parent
      onClicked: {
        //   for (let i = 0; i < rootRectangle.fonts.length; ++i) {
        //     console.log("[" + i + "]: " + rootRectangle.fonts[i]);
        //   }

        // let mName = "xyzdelete";
        // let mNameHash = Qt.md5(mName);
        // ApplicationWindow.window.title = "THe hash of the name is: " + mNameHash;

        // Qt.openUrlExternally("https://github.com/xyzdelete");

        ApplicationWindow.window.title = "The current platform is: " + Qt.platform.os;
      }
    }
  }
}
