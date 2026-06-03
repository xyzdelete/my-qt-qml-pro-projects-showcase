pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.XmlListModel

ApplicationWindow {
  id: rootId
  width: 1280
  height: 720
  visible: true
  Material.foreground: "black"

  XmlListModel {
    id: xmlListModelId
    source: "xml/employees.xml"
    query: "/courses/course"

    XmlListModelRole {
      name: "instructor"
      elementName: "instructor"
    }
    XmlListModelRole {
      name: "year"
      elementName: "year"
    }
    XmlListModelRole {
      name: "coursename"
      elementName: "coursename"
    }
    XmlListModelRole {
      name: "hot"
      elementName: "coursename"
      attributeName: "hot"
    }
  }

  ListView {
    id: listViewId
    anchors.fill: parent
    model: xmlListModelId
    delegate: Rectangle {
      id: rectId
      required property var instructor
      required property var coursename
      required property var year
      required property var hot
      width: parent.width
      height: 50
      color: "beige"

      Row {
        spacing: 30
        id: rowId
        Text {
          text: rectId.instructor
          font.pointSize: 15
        }
        Text {
          text: rectId.coursename + "(" + rectId.year + ")"
          font.pointSize: 15
          font.bold: rectId.hot === "true" ? true : false
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: function() {
          print("Clicked " + rectId.coursename)
        }
      }
    }
  }
}
