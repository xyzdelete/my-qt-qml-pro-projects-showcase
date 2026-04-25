import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  SwipeView {
    id: swipeViewId
    anchors.fill: parent
    currentIndex: pageIndicatorId.currentIndex
    anchors.bottomMargin: 20

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

    onCurrentIndexChanged: function() {
      print("Current index: " + currentIndex)
    }
  }

  PageIndicator {
    id: pageIndicatorId
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter

    currentIndex: swipeViewId.currentIndex
    interactive: true
    count: swipeViewId.count
  }
}