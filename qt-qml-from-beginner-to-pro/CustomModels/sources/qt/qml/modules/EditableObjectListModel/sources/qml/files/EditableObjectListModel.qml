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
    model: Wrapper.persons
    delegate: Rectangle {
      id: delegateId
      required property var modelData
      required property var index
      height: 90
      radius: 10
      color: "gray"
      border.color: "cyan"
      width: parent.width
      RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        TextField {
          text: delegateId.modelData.names
          Layout.fillWidth: true
          background: Rectangle {
            color: "white"
          }

          onEditingFinished: {
            Wrapper.setNames(delegateId.index, text);
          }
        }
        SpinBox {
          editable: true
          value: delegateId.modelData.age
          Layout.fillWidth: true
          background: Rectangle {
            color: "white"
          }

          onValueChanged: {
            if (value === delegateId.modelData.age) {} else {
              Wrapper.setAge(delegateId.index, value);
            }
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

  Button {
    id: mButton
    width: parent.width
    anchors.bottom: parent.bottom
    height: 50
    text: "Add Person"
    onClicked: {
      Wrapper.addPerson();
    }
  }
}
