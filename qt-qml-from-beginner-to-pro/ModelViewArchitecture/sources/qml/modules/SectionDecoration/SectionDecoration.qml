pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  ListView {
    id: listViewId
    anchors.fill: parent
    model: listModelId
    delegate: delegateId
    section {
      property: "company"
      criteria: ViewSection.FullString
      delegate: Rectangle {
        required property var section
        id: sectionRectId
        width: parent.width
        height: 50
        color: "red"
        border.color: "yellowgreen"
        radius: 14

        Text {
          id: sectionTextId
          text: sectionRectId.section
          anchors.centerIn: parent
          font.pointSize: 20
        }

        MouseArea {
          anchors.fill: parent
          onClicked: function() {
            print("Clicked on: " + sectionRectId.section)
          }
        }
      }
    }
  }

  ListModel {
    id: listModelId

    ListElement {
      names: "Seth Moris"
      company: "GOOGLE"
    }
    ListElement {
      names: "Miriam Katv"
      company: "GOOGLE"
    }
    ListElement {
      names: "Eugene Fitzgerald"
      company: "GOOGLE"
    }
    ListElement {
      names: "Kantkl Vikney"
      company: "GOOGLE"
    }
    ListElement {
      names: "Mary Beige"
      company: "TESLA"
    }
    ListElement {
      names: "Bamba Pikt"
      company: "TESLA"
    }
    ListElement {
      names: "Jeffery Mor"
      company: "SIEMENS"
    }
    ListElement {
      names: "Pick Mo"
      company: "SIEMENS"
    }
  }

  Component {
    id: delegateId
    Rectangle {
      required property var names
      id: rectangleId
      width: parent.width
      height: 50
      color: "beige"
      border.color: "yellowgreen"
      radius: 14
      Text {
        id: textId
        anchors.centerIn: parent
        font.pointSize: 20
        text: rectangleId.names
      }

      MouseArea {
        anchors.fill: parent
        onClicked: function() {
          print("Clicked on " + rectangleId.names)
        }
      }
    }
  }
}
