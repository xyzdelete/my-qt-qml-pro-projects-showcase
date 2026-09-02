import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

ApplicationWindow {
  id: rootId
  width: 360
  height: 520
  visible: true
  Material.foreground: "black"

  menuBar: MenuBar {
    Menu {
      title: "File"
      Action {
        id: newActionId
        text: "New"
        icon.source: "images/newFileIcon.png"
        onTriggered: function() {
          print("Clicked on New")
        }
      }
      Action {
        id: openActionId
        text: "Open"
        icon.source: "images/openIcon.png"
        onTriggered: function() {
          print("Clicked on Open")
        }
      }
      Action {
        id: saveActionId
        text: "Save"
        icon.source: "images/saveIcon.png"
        onTriggered: function() {
          print("Clicked on Save")
        }
      }
      Action {
        id: saveAsActionId
        text: "SaveAs"
        icon.source: "images/saveAsIcon.png"
        onTriggered: function() {
          print("Clicked on SaveAs")
        }
      }
      MenuSeparator{

      }
      Action {
        id: quitActionId
        text: "Quit"
        icon.source: "images/quitIcon.png"
        onTriggered: function() {
          Qt.quit()
        }
      }
    }

    Menu {
      title: "Edit"
      Action {
        id: cutActionId
        text: "Cut"
        icon.source: "images/cutIcon.png"
        onTriggered: function() {
          print("Clicked on Cut")
        }
      }
      Action {
        id: copyActionId
        text: "Copy"
        icon.source: "images/copyIcon.png"
        onTriggered: function() {
          print("Clicked on Copy")
        }
      }
      Action {
        id: pasteActionId
        text: "Paste"
        icon.source: "images/pasteIcon.png"
        onTriggered: function() {
          print("Clicked on Paste")
        }
      }
      MenuSeparator{

      }
      Action {
        id: undoActionId
        text: "Undo"
        icon.source: "images/undoIcon.png"
        onTriggered: function() {
          print("Clicked on Undo")
        }
      }
      Action {
        id: redoActionId
        text: "Redo"
        icon.source: "images/redoIcon.png"
        onTriggered: function() {
          print("Clicked on Redo")
        }
      }
    }

    Menu {
      id: helpMenuId
      title: "Help"
      Action {
        id: aboutActionId
        text: "About"
        icon.source: "images/info.png"
        onTriggered: function() {
          print("Clicked on About")
        }
      }
    }
  }

  header: ToolBar {
    Material.background: "mintcream"
    Row {
      anchors.fill: parent
      ToolButton {
        action: newActionId
      }
      ToolButton {
        action: saveActionId
      }
      ToolButton {
        action: saveAsActionId
      }
      ToolButton {
        action: quitActionId
      }
    }
  }

  // Main content
  StackView {
    id: stackId
    anchors.fill: parent
    initialItem: Page1 {

    }
  }

  footer: TabBar {
    id: tabBarId
    width: parent.width

    TabButton {
      text: "Page1"
      onClicked: function() {
        stackId.pop()
        stackId.push("Page1.qml")
        print("Numbers of stack items: " + stackId.depth)
      }
    }
    TabButton {
      text: "Page2"
      onClicked: function() {
        stackId.pop()
        stackId.push("Page2.qml")
        print("Numbers of stack items: " + stackId.depth)
      }
    }
    TabButton {
      text: "Page1"
      onClicked: function() {
        stackId.pop()
        stackId.push("Page3.qml")
        print("Numbers of stack items: " + stackId.depth)
      }
    }
  }
}
