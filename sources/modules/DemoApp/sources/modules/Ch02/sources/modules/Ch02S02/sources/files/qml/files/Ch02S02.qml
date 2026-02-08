pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Rectangle {
  id: rootRectangle
  anchors.fill: parent
  color: "transparent"
  border.color: '#0400ff'
  border.width: 1

  property string mString: "https://github.com/xyzdelete"
  property int mInt: 45
  property bool isFemale: false
  property double mDouble: 77.5
  property url mUrl: "https://github.com/xyzdelete"

  property var aNumber: 100
  property var aBool: false
  property var aString: "Hello world!"
  property var anotherString: String("#FF008800")
  property var aColor: Qt.rgba(0.2, 0.3, 0.4, 0.5)
  property var aRect: Qt.rect(10, 10, 10, 10)
  property var aPoint: Qt.point(10, 10)
  property var aSize: Qt.size(10, 10)
  property var aVector3d: Qt.vector3d(100, 100, 100)
  property var anArray: [1, 2, 3, "four", "five", (function () {
        return "six";
      })]
  property var anObject: {
    "foo": 10,
    "bar": 20
  }
  property var aFunction: (function () {
      return "one";
    })
  property var aFont: Qt.font({
    family: "Consolas",
    pointSize: 10,
    bold: false
  })

  property date mDate: "2026-10-02"

  Rectangle {
    width: 200
    height: 100 + rootRectangle.mInt
    anchors.centerIn: parent
    color: rootRectangle.aColor

    Text {
      id: mTextId
      anchors.centerIn: parent
      text: rootRectangle.mString
      font: rootRectangle.aFont
    }
  }

  Component.onCompleted: {
    ApplicationWindow.window.title = "The date is: " + rootRectangle.mDate;
  }
}
