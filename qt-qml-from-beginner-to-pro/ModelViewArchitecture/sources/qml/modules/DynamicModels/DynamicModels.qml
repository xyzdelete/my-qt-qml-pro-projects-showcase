pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  ListModel {
    id: listModelId

    ListElement {
      firstName: "John"
      lastName: "Snow"
    }
    ListElement {
      firstName: "Nicholai"
      lastName: "Itchenko"
    }
    ListElement {
      firstName: "Mitch"
      lastName: "Mathson"
    }
    ListElement {
      firstName: "Ken"
      lastName: "Kologorov"
    }
    ListElement {
      firstName: "Vince"
      lastName: "Luvkyj"
    }
  }

  ColumnLayout {
    anchors.fill: parent

    ListView {
      id: listViewId
      model: listModelId
      delegate: delegateId
      Layout.fillWidth: true
      Layout.fillHeight: true
    }

    Button {
      text: "Add Item"
      onClicked: function() {
        listModelId.append({"firstName": "someName",
                            "lastName": "someLastName"})
      }
      Layout.fillWidth: true
    }
    Button {
      text: "Clear"
      onClicked: function() {
        listModelId.clear()
      }
      Layout.fillWidth: true
    }
    Button {
      text: "Delete Item at index 2"
      onClicked: function() {
        if (listViewId.model.count > 2) {
          listModelId.remove(2, 1)
        } else {
          print("Index is invalid")
        }
      }
      Layout.fillWidth: true
    }
    Button {
      text: "Set Item at index 1"
      onClicked: function() {
        listModelId.set(1, {"firstName": "someName",
                            "lastName": "someLastName"})
      }
      Layout.fillWidth: true
    }
  }

  Component {
    id: delegateId
    Rectangle {
      required property var firstName
      required property var lastName
      id: rectangleId
      width: parent.width
      height: 50
      color: "beige"
      border.color: "yellowgreen"
      radius: 14

      Text {
        id: textId
        anchors.centerIn: parent
        text: rectangleId.firstName + " " + rectangleId.lastName
        font.pointSize: 20
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          print("Clicked on: "  + rectangleId.firstName + " " + rectangleId.lastName)
        }
      }
    }
  }
}
