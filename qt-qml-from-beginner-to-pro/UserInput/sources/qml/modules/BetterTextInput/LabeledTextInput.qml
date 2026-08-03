import QtQuick

Item {
  readonly property alias text: textInputId.text
  property alias label: labelId.text
  property alias placeHolderText: placeHolderId.text

  signal editingFinished

  Row {
    spacing: 10

    Rectangle {
      id: labelRectId
      width: labelId.implicitWidth + 20
      height: labelId.implicitHeight + 20
      color: "dodgerblue"

      Text {
        id: labelId
        anchors.centerIn: parent
      }
    }

    Rectangle {
      id: textInputRectId
      color: "dodgerblue"

      // Set up width and height
      width: placeHolderId.implicitWidth + textInputId.implicitWidth + 20
      height: placeHolderId.implicitHeight + textInputId.implicitHeight + 20

      // Text element representing the placeholder text
      Text {
        id: placeHolderId
        anchors.centerIn: parent
        anchors.fill: parent

        // The text element will only be visible if the text input element
        // doesn't contain any text and if we are not typing text in the
        // textinput element
        visible: !textInputId.text && !textInputId.inputMethodComposing

        verticalAlignment: Text.AlignVCenter
      }

      TextInput {
        id: textInputId
        anchors.centerIn: parent
        anchors.fill: parent
        focus: true
        verticalAlignment: TextInput.AlignVCenter
      }
    }
  }
  Component.onCompleted: {
    // Connecting a signal to a signal
    textInputId.editingFinished.connect(editingFinished)
  }
}