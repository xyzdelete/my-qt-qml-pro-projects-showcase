import QtQuick

Rectangle {
  id: root
  required property string post
  required property bool darkTheme

  x: 2
  width: ListView.view.width - 4
  implicitHeight: Math.max(92, contentColumn.implicitHeight + 32)
  radius: 20
  border.width: 1
  border.color: hoverHandler.hovered ? (root.darkTheme ? "#75e8b0" : "#2d9366") : (root.darkTheme ? "#29435a" : "#b9d4c9")
  gradient: Gradient {
    GradientStop {
      position: 0.0
      color: hoverHandler.hovered ? (root.darkTheme ? "#25465d" : "#f5fffa") : (root.darkTheme ? "#1b3045" : "#ffffff")
    }
    GradientStop {
      position: 1.0
      color: hoverHandler.hovered ? (root.darkTheme ? "#1a354b" : "#e0f2e9") : (root.darkTheme ? "#122235" : "#eaf4ef")
    }
  }

  Behavior on border.color {
    ColorAnimation {
      duration: 120
    }
  }

  HoverHandler {
    id: hoverHandler
  }

  Rectangle {
    width: 5
    radius: 3
    color: root.darkTheme ? "#6ee7a8" : "#2d9366"
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
    }
  }

  Column {
    id: contentColumn
    spacing: 8
    anchors {
      left: parent.left
      leftMargin: 24
      right: parent.right
      rightMargin: 24
      verticalCenter: parent.verticalCenter
    }

    Text {
      text: qsTr("RESPONSE")
      color: root.darkTheme ? "#71dba4" : "#19724f"
      font {
        pixelSize: 11
        weight: Font.DemiBold
        letterSpacing: 1.2
      }
    }

    Text {
      id: textId
      width: parent.width
      text: root.post
      color: root.darkTheme ? "#eef6fb" : "#153047"
      font.pixelSize: 15
      textFormat: Text.PlainText
      wrapMode: Text.WordWrap
      lineHeight: 1.15
    }
  }
}
