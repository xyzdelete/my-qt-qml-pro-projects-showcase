pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls

ApplicationWindow {
  id: rootId
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  CppClass {
    id: cppClassId
  }
  Button {
    id: button1Id
    text: "Send to C++"
    onClicked: function () {
      var arr = ['Apple', 'Banana', 'Avocado', 'Pear', 'Orange'];
      cppClassId.qmlArrayToCpp(arr);
    }
  }

  Button {
    id: button2Id
    text: "Read form C++"
    anchors.top: button1Id.bottom
    onClicked: function () {
      var arr = cppClassId.retrieveStrings();
      print("The length of the array is: " + arr.length);

      arr.forEach(function (element) {
        console.log(element);
      });
    }
  }
}
