import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Dialogs

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  ListView {
    anchors.fill: parent
    id: listViewId
    model: modelId
    // delegate: delegateId
    delegate: Rectangle {
      id: rectangleId
      width: parent.width
      height: 50
      color: "dodgerblue"
      border.color: "black"
      radius: 15
      Text {
        id: textId
        anchors.centerIn: parent
        font.pointSize: 20
        text: country + ": " + capital
      }

      MouseArea {
        anchors.fill: parent
        onClicked: function() {
          print("Clicked on" + country + ": " + capital)
        }
      }
    }
  }

  ListModel {
    id: modelId

    ListElement {
      country: "Germany"
      capital: "Berlin"
    }       

    ListElement {
      country: "Rwanda"
      capital: "Kigali"
    }

    ListElement {
      country: "Kenya"
      capital: "Nairobi"
    } 

    ListElement {
      country: "India"
      capital: "Mumbai"
    } 
  }

  // Component {
  //   id: delegateId
  //   Rectangle {
  //     id: rectangleId
  //     width: parent.width
  //     height: 50
  //     color: "dodgerblue"
  //     border.color: "black"
  //     radius: 15
  //     Text {
  //       id: textId
  //       anchors.centerIn: parent
  //       font.pointSize: 20
  //       text: country + ": " + capital
  //     }
  //   }
  // }
}
