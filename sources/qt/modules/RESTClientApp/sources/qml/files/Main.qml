pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
  id: root
  property bool compactLayout: width < 620
  property bool darkTheme: true
  // qmllint disable unqualified
  readonly property PostModel postModel: PostModel
  // qmllint enable unqualified
  visible: true
  width: 320
  height: 568
  title: qsTr("RESTClientApp")
  color: darkTheme ? "#0b1220" : "#f3f7f6"
  Material.theme: darkTheme ? Material.Dark : Material.Light

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 28
    spacing: 20

    Rectangle {
      id: header
      radius: 28
      gradient: Gradient {
        GradientStop {
          position: 0.0
          color: root.darkTheme ? "#172b4d" : "#dcefe7"
        }
        GradientStop {
          position: 0.55
          color: root.darkTheme ? "#164f63" : "#b7dfcf"
        }
        GradientStop {
          position: 1.0
          color: root.darkTheme ? "#227b68" : "#8cc9ab"
        }
      }
      Layout.fillWidth: true
      Layout.preferredHeight: Math.max(root.compactLayout ? 172 : 132, headerLayout.implicitHeight + 48)

      RowLayout {
        id: headerLayout
        anchors.fill: parent
        anchors.margins: 24
        spacing: 10

        ColumnLayout {
          spacing: 10
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignTop

          Text {
            text: qsTr("RESTClientApp")
            color: root.darkTheme ? "#f4fbff" : "#153047"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            font {
              pixelSize: 30
              weight: Font.DemiBold
            }
          }

          RowLayout {
            id: logoLayout
            spacing: 10

            Image {
              id: logo
              source: root.darkTheme ? "../../resources/assets/icons/base/dark/rounded/RESTClientApp.svg" : "../../resources/assets/icons/base/light/rounded/RESTClientApp.svg"
              sourceSize: Qt.size(96, 96)
              fillMode: Image.PreserveAspectFit
              asynchronous: true
              Layout.preferredWidth: root.compactLayout ? 44 : 68
              Layout.preferredHeight: root.compactLayout ? 44 : 68
              Layout.alignment: Qt.AlignTop
            }

            ColumnLayout {
              spacing: 10
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignTop

              Text {
                text: qsTr("Explore your latest API responses")
                color: root.darkTheme ? "#c6e7e9" : "#476575"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                font {
                  pixelSize: 15
                }
              }

              Text {
                text: qsTr("%n posts", "post count", mListView.count)
                color: root.darkTheme ? "#9af0c4" : "#19724f"
                Layout.fillWidth: true
                font {
                  pixelSize: 13
                  weight: Font.DemiBold
                }
              }
            }

            Button {
              id: themeButton
              text: root.darkTheme ? qsTr("Light") : qsTr("Night")
              hoverEnabled: true
              Layout.preferredWidth: root.compactLayout ? 76 : 96
              Layout.preferredHeight: root.compactLayout ? 52 : 40
              Layout.alignment: Qt.AlignTop
              onClicked: root.darkTheme = !root.darkTheme
              font {
                pixelSize: 13
                weight: Font.DemiBold
              }
              contentItem: Text {
                text: themeButton.text
                color: root.darkTheme ? "#d9f7e7" : "#164f63"
                font: themeButton.font
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }
              background: Rectangle {
                radius: 14
                color: themeButton.hovered ? (root.darkTheme ? "#346178" : "#d4eee2") : (root.darkTheme ? "#24445a" : "#e5f4ed")
                border.width: 1
                border.color: root.darkTheme ? "#4d7184" : "#a7d9c0"
              }
            }
          }
        }
      }
    }

    Rectangle {
      visible: root.postModel.hasError
      radius: 14
      color: root.darkTheme ? "#542934" : "#f7e5e5"
      border.width: 1
      border.color: root.darkTheme ? "#a95a62" : "#df9d9d"
      Layout.fillWidth: true
      Layout.preferredHeight: visible ? 52 : 0

      Text {
        anchors.fill: parent
        anchors.margins: 14
        text: root.postModel.errorMessage
        color: root.darkTheme ? "#ffe6e6" : "#7a2525"
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
      }
    }

    ListView {
      id: mListView
      property int observedCount: 0
      model: root.postModel
      delegate: PostDelegate {
        darkTheme: root.darkTheme
      }
      spacing: 10
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      Layout.fillHeight: true
      Layout.fillWidth: true

      onCountChanged: {
        const previousCount = observedCount;
        observedCount = count;
        if (count === 0) {
          currentIndex = -1;
          return;
        }
        if (count !== previousCount) {
          scrollToLatestTimer.restart();
        }
      }

      Timer {
        id: scrollToLatestTimer
        interval: 0
        onTriggered: {
          if (mListView.count > 0) {
            mListView.currentIndex = mListView.count - 1;
            mListView.positionViewAtIndex(mListView.currentIndex, ListView.End);
          }
        }
      }

      Text {
        anchors.centerIn: parent
        visible: mListView.count === 0
        text: qsTr("No responses yet")
        color: root.darkTheme ? "#8fa5b8" : "#607786"
        font {
          pixelSize: 18
        }
      }
    }

    Flow {
      spacing: 10
      Layout.fillWidth: true
      Layout.preferredHeight: root.compactLayout ? 180 : 52

      Button {
        id: fetchButton
        text: qsTr("Fetch posts")
        width: root.compactLayout ? parent.width : (parent.width - 24) / 3
        height: 52
        hoverEnabled: true
        onClicked: root.postModel.fetchPosts()
        font {
          pixelSize: 15
          weight: Font.DemiBold
        }
        contentItem: Text {
          text: fetchButton.text
          color: root.darkTheme ? "#08251a" : "#123a2b"
          font: fetchButton.font
          wrapMode: Text.WordWrap
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
          radius: 16
          border.width: 1
          border.color: "#9af0c4"
          gradient: Gradient {
            GradientStop {
              position: 0.0
              color: fetchButton.down ? "#76d6a7" : (fetchButton.hovered ? "#b7f5d3" : "#9af0c4")
            }
            GradientStop {
              position: 1.0
              color: fetchButton.down ? "#3fae7d" : (fetchButton.hovered ? "#83e3b1" : "#68d09e")
            }
          }
        }
      }

      Button {
        id: removeButton
        text: qsTr("Remove last")
        width: root.compactLayout ? parent.width : (parent.width - 24) / 3
        height: 52
        hoverEnabled: true
        onClicked: root.postModel.removeLastPost()
        font {
          pixelSize: 15
          weight: Font.DemiBold
        }
        contentItem: Text {
          text: removeButton.text
          color: root.darkTheme ? "#d7e4f0" : "#244052"
          font: removeButton.font
          wrapMode: Text.WordWrap
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
          radius: 16
          color: root.darkTheme ? (removeButton.down ? "#26394f" : (removeButton.hovered ? "#2c4861" : "#17263a")) : (removeButton.down ? "#d5e8e0" : (removeButton.hovered ? "#d9eee5" : "#e8f3ef"))
          border.width: 1
          border.color: root.darkTheme ? "#38516b" : "#acd0c0"
        }
      }

      Button {
        id: clearButton
        text: qsTr("Delete all")
        width: root.compactLayout ? parent.width : (parent.width - 24) / 3
        height: 52
        hoverEnabled: true
        onClicked: root.postModel.removeAllPosts()
        font {
          pixelSize: 15
          weight: Font.DemiBold
        }
        contentItem: Text {
          text: clearButton.text
          color: root.darkTheme ? "#ffe6e6" : "#7a2525"
          font: clearButton.font
          wrapMode: Text.WordWrap
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
          radius: 16
          color: root.darkTheme ? (clearButton.down ? "#7a3038" : (clearButton.hovered ? "#6e3540" : "#542934")) : (clearButton.down ? "#f2c7c7" : (clearButton.hovered ? "#f9dcdc" : "#f7e5e5"))
          border.width: 1
          border.color: root.darkTheme ? "#a95a62" : "#df9d9d"
        }
      }
    }
  }
}
