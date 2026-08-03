import QtQuick
import QtQuick.Layouts

Item {
  ColumnLayout {
    Layout.topMargin: 10
    spacing: 50

    LabeledTextInput {
      id: firstNameId
      label: "First Name: "
      placeHolderText: "Type in your first name..."
      onEditingFinished: {
        print("The first name changed to: " + firstNameId.text)
      }
    }

    LabeledTextInput {
      id: lastNameId
      label: "Last Name: "
      placeHolderText: "Type in your last name..."
      onEditingFinished: {
        print("The last name changed to: " + lastNameId.text)
      }
    }
  }
}