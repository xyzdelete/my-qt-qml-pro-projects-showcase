pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  signal info(string last_name, string first_name, int age)

  onInfo: function (_, f, a) {
    ApplicationWindow.window.title = "first name: " + f + ", age: " + a;
  }

  Rectangle {
    id: rectId
    width: 300
    height: 300
    color: "blue"

    MouseArea {
      anchors.fill: parent
      onClicked: function () {
        rootRectangle.info("Snow", "Bob", 20);
      }
    }
  }
}
