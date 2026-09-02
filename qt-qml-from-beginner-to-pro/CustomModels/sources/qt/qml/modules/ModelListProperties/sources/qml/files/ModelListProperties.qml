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

  PersonModel {
    id: modelId
    /*
        Person{
            names: "Steve Barker"
            favoriteColor: "blue"
            age : 34
        }
        Person{
            names: "John Snow"
            favoriteColor: "yellow"
            age : 33
        }
        Person{
            names: "Daniel Gakwaya"
            favoriteColor: "green"
            age : 23
        }
        */

    persons: [
      Person {
        names: "Daniel Gakwaya"
        favoriteColor: "yellow"
        age: 34
      },
      Person {
        names: "Gwiza Luna"
        favoriteColor: "blue"
        age: 1
      },
      Person {
        names: "Steve Barker"
        favoriteColor: "yellowgreen"
        age: 22
      }
    ]
  }

  ColumnLayout {
    anchors.fill: parent
    ListView {
      id: mListView
      Layout.fillWidth: true
      Layout.fillHeight: true

      model: modelId
      delegate: Rectangle {
        id: delegateId
        required property var model
        required property var index
        required property var modelData
        height: 90
        radius: 10
        color: "gray"// Can also do modelData.favoriteColor directly but adding model makes it clear where the data is coming from. More readable
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
              delegateId.model.names = text; //The roles here are defined in model class

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
              delegateId.model.age = value;
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
                  delegateId.model.favoriteColor = colorDialog.selectedColor;
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
            modelId.addPerson(personNames, "yellowgreen", personAge);
          }
        }
      }
      Button {
        Layout.fillWidth: true
        height: 50
        text: "Remove Last"
        onClicked: {
          modelId.removeLastItem();
        }
      }
    }
  }
}
