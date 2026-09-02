pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls

ApplicationWindow {
  objectName: "rootWindow"
  width: 640
  height: 480
  visible: true
  title: qsTr("QQmlApplicationEngine")

  Item {
    objectName: "deep1"
    Item {
      objectName: "deep2"
      function qmlFunction(value) {
        console.log("QML function called, the parameter is :" + value);
        return "Return value from QML";
      }
    }
  }
}
