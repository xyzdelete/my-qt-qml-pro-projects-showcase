import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  ColumnLayout {
    anchors.fill: parent
    Label {
      text: "Non Editable Combo"
      wrapMode: Label.Wrap
      Layout.fillWidth: true
    }

    ComboBox {
      id: nonEditableComboId
      model: ["One", "Two", "Three", "Four"]
      Layout.fillWidth: true
      onActivated: {
        print("[" + currentIndex + "] " + currentText + " is activated")
      }
    }

    Label {
      text: "Editable Combo"
      wrapMode: Label.Wrap
      Layout.fillWidth: true
    }

    ComboBox {
      id: editableComboId
      editable: true
      textRole: "text"
      Layout.fillWidth: true
      model: ListModel {
        id: modelId
        ListElement {
          text: "Dog"
          location: "Kigali"
          favorite_food: "Meat"
        }
        ListElement {
          text: "Chicken"
          location: "Nairobi"
          favorite_food: "Rice"
        }
        ListElement {
          text: "Cat"
          location: "India"
          favorite_food: "Fish"
        }
      }
      onActivated: {
        print("[" + currentIndex + "] " + currentText + " is activated")
      }
      onAccepted: function() {
        if(find(editableComboId.editText) === -1) {
          modelId.append({ text: editableComboId.editText, location: "US", favorite_food: "Apple"})
        }
      }
    }

    Button {
      text: "Capture current element"
      Layout.fillWidth: true
      onClicked: {
        print(modelId.get(editableComboId.currentIndex).text + ", "
        + modelId.get(editableComboId.currentIndex).location)
      }
    }

    Item {
      Layout.fillHeight: true
    }
  }
}