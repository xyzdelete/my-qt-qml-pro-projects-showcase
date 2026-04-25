import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  Column {
    spacing: 10
    anchors.fill: parent

    Label {
      width: parent.width
      wrapMode: Label.Wrap
      horizontalAlignment: Qt.AlignCenter
      text: "A GroupBox wrapping around RadioButtons"
    }

    GroupBox {
      title: "Choose bonus"
      anchors.horizontalCenter: parent.horizontalCenter
      Column {
        RadioButton {
          text: "Coke"
          onCheckedChanged: function() {
            if (checked) {
              print("Coke button checked")
            }
            else {
              print("Coke button NOT checked")
            }
          }
        }
        RadioButton {
          text: "Green Tee"
          onCheckedChanged: function() {
            if (checked) {
              print("Green Tee button checked")
            }
            else {
              print("Green Tee button NOT checked")
            }
          }
        }
        RadioButton {
          text: "Ice Cream"
          onCheckedChanged: function() {
            if (checked) {
              print("Ice Cream Tee button checked")
            }
            else {
              print("Ice Cream Tee button NOT checked")
            }
          }
        }
      }
    }
    Label {
      width: parent.width
      wrapMode: Label.Wrap
      horizontalAlignment: Qt.AlignCenter
      text: "A GroupBox wrapping around CheckBoxes"
    }

    GroupBox {
      title: "Choose a Qt supported desktop platform"
      anchors.horizontalCenter: parent.horizontalCenter
      Column {
        CheckBox {
          text: "Windows"
          onCheckedChanged: function() {
            if (checked) {
              print("Windows button checked")
            }
            else {
              print("Windows button NOT checked")
            }
          }
        }
        CheckBox {
          text: "Mac"
          onCheckedChanged: function() {
            if (checked) {
              print("Mac button checked")
            }
            else {
              print("Mac button NOT checked")
            }
          }
        }
        CheckBox {
          text: "Linux"
          onCheckedChanged: function() {
            if (checked) {
              print("Linux button checked")
            }
            else {
              print("Linux button NOT checked")
            }
          }
        }
      }
    }

    Label {
      width: parent.width
      wrapMode: Label.Wrap
      horizontalAlignment: Qt.AlignCenter
      text: "A GroupBox that can be enabled and disabled"
    }

    GroupBox {
      anchors.horizontalCenter: parent.horizontalCenter
      label: CheckBox {
        id: checkBoxId
        checked: true
        text: checked ? "Disable" : "Enable"
        onCheckedChanged: function() {
          print("Status: " + text + "d")
        }
      }

      Column {
        enabled: checkBoxId.checked
        CheckBox {
          text: "Item1"
        }
        CheckBox {
          text: "Item2"
        }
        CheckBox {
          text: "Item3"
        }
      }
    }
  }
}