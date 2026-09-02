pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  function fetchData(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
      if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
        print("HEADERS_RECEIVED");
      } else if (xhr.readyState === XMLHttpRequest.DONE) {
        print("DONE");
        if (xhr.status === 200) {
          print("resource found" + xhr.responseText.toString());

          callback(xhr.responseText.toString());
        } else {
          callback(null);
        }
      }
    };

    xhr.open("GET", url);
    xhr.send();
  }

  ColumnLayout {
    anchors.fill: parent

    spacing: 0

    ListModel {
      id: listModelId
    }

    ListView {
      id: listViewId
      model: listModelId
      delegate: delegateId
      Layout.fillWidth: true
      Layout.fillHeight: true
    }

    Button {
      Layout.fillWidth: true
      text: "Fetch"
      onClicked: function () {
        listModelId.clear();

        rootId.fetchData("https://jsonplaceholder.typicode.com/users", function (response) {
          if (response) {
            // Parse the data
            let object = JSON.parse(response);

            object.forEach(function (userdata) {
              listModelId.append({
                "userdata": userdata.name
              });
            });
          } else {
            print("Something went wrong");
          }
        });
      }
    }

    Component {
      id: delegateId
      Rectangle {
        id: rectangleId
        required property var model
        width: parent.width
        height: textId.implicitHeight + 30
        color: "beige"
        border.color: "yellowgreen"
        radius: 5

        Text {
          id: textId
          anchors.centerIn: parent
          text: rectangleId.model.userdata
          font.pointSize: 13
          wrapMode: Text.WordWrap
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }
}
