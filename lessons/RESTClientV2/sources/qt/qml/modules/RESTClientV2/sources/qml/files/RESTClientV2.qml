pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
  id: root
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    ListView {
      id: mListView
      model: PostModel
      delegate: Rectangle {
        id: delegateId
        required property var model

        width: root.width
        height: textId.implicitHeight + 30
        color: "beige"
        border.color: "yellowgreen"
        radius: 5

        Text {
          id: textId
          width: parent.width
          height: parent.height
          anchors.centerIn: parent
          text: delegateId.model.post // The role we exposed in C++
          //text : modelData // Can also use  this
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
      id: mButton1
      text: "Fetch"
      Layout.fillWidth: true
      onClicked: {
        PostModel.datasource.fetchPosts();
      }
    }
    Button {
      id: mButton2
      text: "RemoveLast"
      Layout.fillWidth: true
      onClicked: {
        PostModel.datasource.removeLastPost();
      }
    }
  }
}
