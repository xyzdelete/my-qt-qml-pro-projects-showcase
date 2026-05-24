pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import QtQuick.Dialogs
import QtCore
import QtQuick.LocalStorage
import "Database.js" as JS

ApplicationWindow {
  id: rootId
  visible: true
  Material.foreground: "black"
  property var db

  Rectangle {
    id: rectId
    anchors.fill: parent
    color: "red"

    MouseArea {
      anchors.fill: parent
      onClicked: function () {
        colorDialogId.open();
      }

      ColorDialog {
        id: colorDialogId
        title: "choose color"
        onAccepted: function () {
          rectId.color = selectedColor;
        }
        onRejected: function () {
          print("Dialog rejected");
        }
      }
    }
  }
  Component.onCompleted: {
    // Init the db
    JS.dbInit();
    // Read the data
    JS.readData();
  }
  Component.onDestruction: {
    // Store the data
    JS.storeData();
  }
}
