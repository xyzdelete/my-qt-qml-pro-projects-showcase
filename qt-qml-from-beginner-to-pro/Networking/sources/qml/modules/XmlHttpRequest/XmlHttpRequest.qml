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

  // // Process the data right away
  // function downloadData(url) {
  //   // Create the object
  //   var xhr = new XMLHttpRequest();

  //   // Apply initial settings to the object
  //   xhr.onreadystatechange = function () {
  //     // HEADERS_RECEIVED

  //     // DONE

  //     if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
  //       print("Headers received");
  //     } else if (xhr.readyState === XMLHttpRequest.DONE) {
  //       if (xhr.status === 200) {
  //         print("Got the datga from the server it is : " + xhr.responseText.toString());
  //         textAreaId.text = xhr.responseText.toString();
  //       } else {
  //         print("Something went wrong");
  //       }
  //     }
  //   };

  //   xhr.open("GET", url);
  //   xhr.send();
  // }

  // Go through a callback
  function downloadData(url, callback) {
    // Create the object
    var xhr = new XMLHttpRequest();

    // Apply initial settings to the object
    xhr.onreadystatechange = function () {
      // HEADERS_RECEIVED

      // DONE

      if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
        print("Headers received");
      } else if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
          print("Got the datga from the server it is : " + xhr.responseText.toString());
          // textAreaId.text = xhr.responseText.toString();
          callback(xhr.responseText.toString());
        } else {
          print("Something went wrong");
        }
      }
    };

    xhr.open("GET", url);
    xhr.send();
  }

  TextArea {
    id: textAreaId
    anchors.fill: parent
    textFormat: TextArea.RichText
    text: "Click to download html data"
  }

  MouseArea {
    anchors.fill: parent
    onClicked: function () {
      // Download data right away
      //rootId.downloadData("https://www.qt.io");

      // Download data through a callback
      rootId.downloadData("https://www.qt.io", function (response) {
        if (response) {
          textAreaId.text = response;
        } else {
          print("Something went wrong");
        }
      });
    }
  }
}
