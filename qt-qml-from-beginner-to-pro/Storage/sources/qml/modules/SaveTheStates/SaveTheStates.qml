pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import QtCore

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  Rectangle {
    id: containerRectId
    anchors.fill: parent

    // Sky
    Rectangle {
      id: skyId
      width: parent.width
      height: 200
      // color: "lightblue"
      gradient: Gradient {
        GradientStop {
          id: skyStartColorId
          position: 0.0
          color: "blue"
        }
        GradientStop {
          id: skyEndColorId
          position: 1.0
          color: "#66CCFF"
        }
      }
    }

    // Ground
    Rectangle {
      id: groundId
      anchors.top: skyId.bottom
      anchors.bottom: parent.bottom
      width: parent.width
      // color: "lime"
      gradient: Gradient {
        GradientStop {
          id: groundStartColorId
          position: 0.0
          color: "lime"
        }
        GradientStop {
          id: groundEndColorId
          position: 1.0
          color: "green"
        }
      }
    }

    Image {
      id: treeSummerId
      x: 50
      y: 100
      width: 200
      height: 300
      source: "images/treesummersmall.png"
    }

    Image {
      id: treeSpringId
      x: 50
      y: 100
      width: 200
      height: 300
      source: "images/treespringsmall.png"
    }

    Rectangle {
      id: sunId
      x: parent.width - width - 100
      y: 50
      width: 100
      height: 100
      color: "yellow"
      radius: 50
    }

    // transitions: [
    //   Transition {
    //     from: "summer"
    //     to: "spring"
    //     ColorAnimation {
    //       duration: 500
    //     }
    //     NumberAnimation {
    //       property: "opacity"
    //       duration: 500
    //     }
    //   },
    //   Transition {
    //     from: "spring"
    //     to: "summer"
    //     ColorAnimation {
    //       duration: 500
    //     }
    //     NumberAnimation {
    //       property: "opacity"
    //       duration: 500
    //     }
    //   }
    // ]

    transitions: [
      Transition {
        from: "*"
        to: "*"
        ColorAnimation {
          duration: 500
        }
        NumberAnimation {
          property: "opacity"
          duration: 500
        }
      }
    ]

    state: settingsId.state

    states: [
      // Spring
      State {
        name: "spring"
        // PropertyChanges {
        //   target: skyId
        //   color: "deepskyblue"
        // }
        PropertyChanges {
          target: skyStartColorId
          color: "deepskyblue"
        }
        PropertyChanges {
          target: skyEndColorId
          color: "#AACCFF"
        }
        PropertyChanges {
          target: treeSummerId
          opacity: 0
        }
        PropertyChanges {
          target: treeSpringId
          opacity: 1
        }
        // PropertyChanges {
        //   target: groundId
        //   color: "lime"
        // }
        PropertyChanges {
          target: sunId
          color: "lightyellow"
        }
        PropertyChanges {
          target: groundStartColorId
          color: "lime"
        }
        PropertyChanges {
          target: groundEndColorId
          color: "#66CCFF"
        }
      },
      State {
        // Summer
        name: "summer"
        // PropertyChanges {
        //   target: skyId
        //   color: "lightblue"
        // }
        PropertyChanges {
          target: skyStartColorId
          color: "#66CCFF"
        }
        PropertyChanges {
          target: skyEndColorId
          color: "lightblue"
        }
        PropertyChanges {
          target: treeSummerId
          opacity: 1
        }
        PropertyChanges {
          target: treeSpringId
          opacity: 0
        }
        // PropertyChanges {
        //   target: groundId
        //   color: "darkkhaki"
        // }
        PropertyChanges {
          target: sunId
          color: "yellow"
        }
        PropertyChanges {
          target: groundStartColorId
          color: "darkkhaki"
        }
        PropertyChanges {
          target: groundEndColorId
          color: "lime"
        }
      }
    ]
    MouseArea {
      anchors.fill: parent
      onClicked: function () {
        containerRectId.state = (containerRectId.state === "spring") ? "summer" : "spring";
      }
    }
    Settings {
      id: settingsId
      property string state: "spring"
    }
  }

  Component.onDestruction: function () {
    settingsId.state = containerRectId.state;
  }
}
