import QtQuick
import QtQuick.Layouts

Item {
  width: parent.width
  height: parent.height
  anchors.centerIn: parent
  Column {
    spacing: 20
    anchors.centerIn: parent
    CustomElement{
        color: "yellow"
        focus: true
    }

    CustomElement{
        color: "green"
        //focus: true
    }    
  }
}