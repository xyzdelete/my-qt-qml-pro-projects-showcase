import QtQuick

Item {
  Rectangle {
    id: rectId
    width: 150
    height: 150
    color: "blue"

    signal info(string last_name, string first_name, string age)

    // onInfo: function (l, f, a) {
    //   print("last name: " + l + ", first_name: " + f + ", age: " + a)
    // }
    
    // onInfo: function (l, f) {
    //   print("last name: " + l + ", first_name: " + f)
    // }

    onInfo: function (_, f, a) {
      print("first name: " + f + ", age: " + a)
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        rectId.info("L", "F", "A")
      }
    }
  }
}
