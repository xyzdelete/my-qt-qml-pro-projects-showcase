pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import QtQuick.Dialogs
import QtCore
import QtQuick.LocalStorage

ApplicationWindow {
  id: rootId
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  Column {
    spacing: 10
    anchors.right: parent.right

    Row {
      spacing: 10
      Text {
        text: qsTr("regularMethod")
      }
      Button {
        text: "Call C++ method"
        onClicked: function () {
          BWorker.regularMethod();
        }
      }
    }
    Row {
      spacing: 10
      Text {
        text: qsTr("cppSlot")
      }
      Button {
        text: qsTr("Call C++ method")
        onClicked: function () {
          BWorker.cppSlot();
        }
      }
    }
    Row {
      spacing: 10
      Text {
        id: returnTextId
        text: qsTr("return")
      }
      Text {
        text: qsTr("regularMethodWithReturn(")
      }
      TextField {
        id: nameFieldId
        placeholderText: qsTr("name")
        text: qsTr("John")
      }
      Text {
        text: qsTr(",")
      }
      TextField {
        id: ageFieldId
        placeholderText: qsTr("age")
        inputMethodHints: Qt.ImhDigitsOnly
        text: qsTr("25")
      }
      Text {
        text: qsTr(")")
      }
      Button {
        text: qsTr("Call C++ method")
        onClicked: function () {
          if (nameFieldId.text !== null && ageFieldId.text !== null) {
            let response = BWorker.regularMethodWithReturn(nameFieldId.text, parseInt(ageFieldId.text));
            returnTextId.text = response;
          } else {
            print("One of the two required fields are empty");
          }
        }
      }
    }
  }
}
