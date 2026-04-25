import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  Page {
    id: pageId
    anchors.fill: parent

    header: Rectangle {
      width: parent.width
      height: 50
      color: "yellowgreen"
      Text {
        text: "Some header text"
        anchors.centerIn: parent
      }
    }

    SwipeView {
      id: swipeViewId
      anchors.fill: parent
      currentIndex: tabBarId.currentIndex

      Image {
        id: image1
        fillMode: Image.PreserveAspectFit
        source: "images/1.png"
      }
      Image {
        id: image2
        fillMode: Image.PreserveAspectFit
        source: "images/2.png"
      }
      Image {
        id: image3
        fillMode: Image.PreserveAspectFit
        source: "images/3.png"
      }
    }

    footer: TabBar {
      id: tabBarId
      currentIndex: swipeViewId.currentIndex

      TabButton {
        text: "First"
      }
      TabButton {
        text: "Second"
      }
      TabButton {
        text: "Third"
      }
    }
  }
}