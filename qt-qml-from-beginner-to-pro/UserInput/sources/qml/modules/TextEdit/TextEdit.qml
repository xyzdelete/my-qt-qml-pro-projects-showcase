import QtQuick
import QtQuick.Layouts

Item {
  TextEdit {
    width: 240
    text: "<b>Hello</b> <i>World!</i>"
    font.family: "Helvetica"
    font.pointSize: 20
    color: "blue"
    focus: true
    wrapMode: TextEdit.Wrap
    textFormat: TextEdit.RichText
    onEditingFinished: {
      print("The current text is: " + text)
    }
  }
}