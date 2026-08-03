import QtQuick

Item {
  width: Constants.windowWidth
  height: Constants.windowHeight
  anchors.fill: parent

  // Components
  Column {
    x: 10
    y: 10
    MButton {
      buttonText: "Button1"
      onButtonClicked: {
        Utils.buttonAlert(buttonText)
      }
    }
    MButton {
      buttonText: "Button2"
      onButtonClicked: {
        Utils.buttonAlert(buttonText)
      }
    }
  }
}