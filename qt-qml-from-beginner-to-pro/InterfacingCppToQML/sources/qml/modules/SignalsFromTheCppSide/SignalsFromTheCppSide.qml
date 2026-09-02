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

  Connections {
    target: CppSignalSender
    function onCallQml(parameter) {
      print("This is QML: callQml signal caught.");
    }

    function onCppTimer(value) {
      mRectText.text = value;
    }
  }
  Column {
    Rectangle {
      width: 200
      height: 200
      color: "red"
      radius: 10

      Text {
        id: mRectText
        text: "0"
        anchors.centerIn: parent
        color: "white"
        font.pointSize: 30
      }
    }

    Button {
      text: "Call C++ Method"
      onClicked: {
        CppSignalSender.cppSlot();
      }
    }

    Text {
      id: mText
      text: qsTr("Default")
    }
  }
}
