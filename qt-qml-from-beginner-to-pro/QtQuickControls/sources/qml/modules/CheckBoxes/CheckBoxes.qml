import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  Column {
    spacing: 20
    anchors.horizontalCenter: parent.horizontalCenter

    CheckBox {
      text: "Option1"
      checked: true
      onCheckedChanged: function() {
        if (checked)
        {
          print("Option1 is checked")
        }
        else
        {
          print("Option1 is unchecked")
        }
      }
    }

    CheckBox {
      text: "Option2"
    }

    CheckBox {
      text: "Option3"
      checked: true
      enabled: false
    }
  }
}