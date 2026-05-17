pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
  id: rootId
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  AppWrapper {
    id: appWrapperId
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    ListView {
      id: mListView
      model: myModel
      delegate: Rectangle {
        id: delegateId
        required property string modelData

        width: rootId.width
        height: textId.implicitHeight + 30
        color: "beige"
        border.color: "yellowgreen"
        radius: 5

        Text {
          id: textId
          width: parent.width
          height: parent.height
          anchors.centerIn: parent
          text: delegateId.modelData
          font.pointSize: 13
          wrapMode: Text.WordWrap
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }
      }
      Layout.fillHeight: true
      Layout.fillWidth: true
    }

    Button {
      id: button1Id
      text: "Fetch"
      Layout.fillWidth: true
      onClicked: {
        Wrapper.fetchPosts();
      }
    }
    Button {
      id: button2Id
      text: "RemoveLast"
      Layout.fillWidth: true
      onClicked: {
        Wrapper.removeLast();
      }
    }
  }
}
