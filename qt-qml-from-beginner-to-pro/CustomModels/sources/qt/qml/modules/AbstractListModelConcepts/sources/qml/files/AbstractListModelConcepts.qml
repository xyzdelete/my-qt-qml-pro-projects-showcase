pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
  id: root
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  ColumnLayout {
    anchors.fill: parent
    PersonModel {
      id: modelId
    }

    ListView {
      id: mListView
      Layout.fillWidth: true
      Layout.fillHeight: true
      model: modelId
      delegate: Rectangle {
        id: delegateId
        required property var modelData
        required property var index
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

            onEditingFinished: {
              console.log("Editing finished, new text is :" + text + " at index :" + delegateId.index);
              delegateId.modelData.names = text; //The roles here are defined in model class

            }
          }

          SpinBox {
            id: mSpinbox
            editable: true
            Layout.fillWidth: true
            background: Rectangle {
              color: "white"
            }

            onValueChanged: {
              delegateId.modelData.age = value;
            }
            Component.onCompleted: {
              mSpinbox.value = delegateId.modelData.age;
            }
          }
          Rectangle {
            width: 50
            height: 50
            color: delegateId.modelData.favoriteColor
            MouseArea {
              anchors.fill: parent
              ColorDialog {
                id: colorDialog
                title: "Please choose a color"
                onAccepted: {
                  console.log("You chose: " + colorDialog.selectedColor);
                  delegateId.modelData.favoriteColor = colorDialog.selectedColor;
                }
                onRejected: {
                  console.log("Canceled");
                }
              }

              onClicked: {
                colorDialog.open();
              }
            }
          }
        }
      }
    }

    RowLayout {
      width: parent.width
      Button {
        Layout.fillWidth: true
        height: 50
        text: "Add Person"
        onClicked: {
          input.openDialog();
        }
        InputDialog {
          id: input
          onInputDialogAccepted: {
            console.log("Here in main, dialog accepted");
            console.log(" names : " + personNames + " age :" + personAge);
            modelId.addPerson(personNames, personAge);
          }
        }
      }
      Button {
        Layout.fillWidth: true
        height: 50
        text: "Remove Last"
        onClicked: {
          modelId.removeLastPerson();
        }
      }
    }
  }
}
