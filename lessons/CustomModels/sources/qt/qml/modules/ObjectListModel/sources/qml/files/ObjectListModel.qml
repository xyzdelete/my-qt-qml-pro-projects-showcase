pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
  id: root
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  ListView {
    id: mListView
    anchors.fill: parent
    model: personModel
    // model: modelId
    delegate: Rectangle {
      id: delegateId
      required property var modelData
      height: 90
      radius: 10
      color: "gray"
      border.color: "cyan"
      width: root.width
      RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        TextField {
          text: delegateId.modelData.names
          Layout.fillWidth: true
          background: Rectangle {
            color: "white"
          }
        }
        SpinBox {
          editable: true
          value: delegateId.modelData.age
          Layout.fillWidth: true
          background: Rectangle {
            color: "white"
          }
        }
        Rectangle {
          width: 50
          height: 50
          color: delegateId.modelData.favoriteColor
        }
      }
    }
  }

  ListModel {
    id: modelId
    ListElement {
      names: "Daniel Sten"
      favoriteColor: "blue"
      age: 10
    }
    ListElement {
      names: "Stevie Wongers"
      favoriteColor: "cyan"
      age: 23
    }
    ListElement {
      names: "Nicholai Ven"
      favoriteColor: "red"
      age: 33
    }
    ListElement {
      names: "William Glen"
      favoriteColor: "yellowgreen"
      age: 45
    }
  }
}
