import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
  anchors.fill: parent

  Column {
    anchors.fill: parent
    spacing: 20

    Label {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottomMargin: 150

      wrapMode: Label.Wrap
      horizontalAlignment: Qt.AlignHCenter
      text: "TextArea is a multi-line text editor."
    }

    ScrollView {
      id: scrollViewId
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width
      height: 150

      TextArea {
        id: textAreaId
        font.pointSize: 15
        wrapMode: TextArea.WordWrap
        placeholderText: "Type in some text"
      }
    }

    Button {
      text: "Submit"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: function() {
        print("The text is: " + textAreaId.text)
        textAreaId.text = "Hello World!"
      }
    }
  }
}