import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Dialogs

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  readonly property int buttonWidth: 300

  Column {
    spacing: 20
    anchors.centerIn: parent

    Label {
      width: parent.width
      wrapMode: Label.Wrap
      horizontalAlignment: Qt.AlignHCenter
      text: qsTr("Dialog is a popup that is mostly used for short-term tasks "
          + "and brief communications with the user.")
    }

    Button {
      text: qsTr("Message")
      anchors.horizontalCenter: parent.horizontalCenter
      width: rootId.buttonWidth
      onClicked: messageDialog.open()

      Dialog {
        id: messageDialog

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        title: qsTr("Message")

        Label {
            text: qsTr("Lorem ipsum dolor sit amet...")
        }
      }
    }

    Button {
      id: button
      text: qsTr("Confirmation")
      anchors.horizontalCenter: parent.horizontalCenter
      width: rootId.buttonWidth
      onClicked: confirmationDialog.open()

      Dialog {
        id: confirmationDialog

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        parent: Overlay.overlay

        modal: true
        title: qsTr("Confirmation")
        standardButtons: Dialog.Yes | Dialog.No

        Column {
          spacing: 20
          anchors.fill: parent
          Label {
              text: qsTr("The document has been modified.\nDo you want to save your changes?")
          }
          CheckBox {
              text: qsTr("Do not ask again")
              anchors.right: parent.right
          }
        }
      }
    }
    Button {
      text: qsTr("Content")
      anchors.horizontalCenter: parent.horizontalCenter
      width: rootId.buttonWidth
      onClicked: contentDialog.open()

      Dialog {
        id: contentDialog

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: Math.min(rootId.width, rootId.height) / 3 * 2
        contentHeight: logo.height * 2
        parent: Overlay.overlay

        modal: true
        title: qsTr("Content")
        standardButtons: Dialog.Close

        Flickable {
          id: flickable
          clip: true
          anchors.fill: parent
          contentHeight: column.height

          Column {
            id: column
            spacing: 20
            width: parent.width

            Image {
              id: logo
              width: parent.width / 2
              anchors.horizontalCenter: parent.horizontalCenter
              fillMode: Image.PreserveAspectFit
              source: "images/LearnQtLogo.png"
            }

            Label {
                width: parent.width
                text: qsTr("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc finibus "
                  + "in est quis laoreet. Interdum et malesuada fames ac ante ipsum primis "
                  + "in faucibus. Curabitur eget justo sollicitudin enim faucibus bibendum. "
                  + "Suspendisse potenti. Vestibulum cursus consequat mauris id sollicitudin. "
                  + "Duis facilisis hendrerit consectetur. Curabitur sapien tortor, efficitur "
                  + "id auctor nec, efficitur et nisl. Ut venenatis eros in nunc placerat, "
                  + "eu aliquam enim suscipit.")
                wrapMode: Label.Wrap
            }
          }

          ScrollIndicator.vertical: ScrollIndicator {
            parent: contentDialog.contentItem
            anchors.top: flickable.top
            anchors.bottom: flickable.bottom
            anchors.right: parent.right
            anchors.rightMargin: -contentDialog.rightPadding + 1
          }
        }
      }
    }
    Button {
      text: qsTr("Input")
      anchors.horizontalCenter: parent.horizontalCenter
      width: rootId.buttonWidth
      onClicked: inputDialog.open()

      Dialog {
        id: inputDialog

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        parent: Overlay.overlay

        focus: true
        modal: true
        title: qsTr("Input")
        standardButtons: Dialog.Ok | Dialog.Cancel

        ColumnLayout {
          spacing: 20
          anchors.fill: parent
          Label {
            elide: Label.ElideRight
            text: qsTr("Please enter the credentials:")
            Layout.fillWidth: true
          }
          TextField {
            focus: true
            placeholderText: qsTr("Username")
            Layout.fillWidth: true
          }
          TextField {
            placeholderText: qsTr("Password")
            echoMode: TextField.PasswordEchoOnEdit
            Layout.fillWidth: true
          }
        }
      }
    }
  }
}
