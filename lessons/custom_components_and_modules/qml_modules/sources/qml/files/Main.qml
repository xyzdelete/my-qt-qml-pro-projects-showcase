import QtQuick
import GreatButtons

Window {
  width: 640
  height: 480
  visible: true
  title: qsTr("Custom Components in place")

  Column {
    x: 10
    y: 10
    YellowButton {
      buttonText: "Button1"
      onButtonClicked: {
        print("Clicked on component button1")
      }
    }
    RedButton {
      buttonText: "Button2"
      onButtonClicked: {
        print("Clicked on component button2")
      }
    }
    GreenButton {
      buttonText: "Button3"
      onButtonClicked: {
        print("Clicked on component button3")
      }
    }
    GrayButton {
      buttonText: "Button4"
      onButtonClicked: {
        print("Clicked on component button4")
      }
    }
  }
}
