pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls

ApplicationWindow {
  id: root
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  property var myApi: SingletonClass //We instantiate the class object on the QML side.

  /*
       Rectangle {
           id : rect1Id
           width: 200
           height: 200
           radius: 10
           color: "red"

           Text {
               id: mText1Id
               anchors.centerIn: parent
               color: "white"
               font.pointSize: 30
               text: MyApi.someProperty
           }
       }

       Rectangle {
           id : rect2Id
           width: 200
           height: 200
           radius: 10
           anchors.left: rect1Id.right
           anchors.leftMargin: 20
           color: "blue"

           Text {
               id: mText2Id
               anchors.centerIn: parent
               color: "white"
               font.pointSize: 30
               text: MyApi.someProperty
           }
       }
       */

  Rectangle {
    id: rect1Id
    width: 200
    height: 200
    radius: 10
    color: "red"

    Text {
      id: mText1Id
      anchors.centerIn: parent
      color: "white"
      font.pointSize: 30
      text: myApi.someProperty
    }
  }

  Rectangle {
    id: rect2Id
    width: 200
    height: 200
    radius: 10
    anchors.left: rect1Id.right
    anchors.leftMargin: 20
    color: "blue"

    Text {
      id: mText2Id
      anchors.centerIn: parent
      color: "white"
      font.pointSize: 30
      text: myApi.someProperty
    }
  }
}
