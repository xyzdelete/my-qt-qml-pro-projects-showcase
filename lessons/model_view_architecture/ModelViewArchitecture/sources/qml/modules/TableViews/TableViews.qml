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

  HorizontalHeaderView {
    id: horizontalHeaderViewId
    anchors.left: tableViewId.left
    anchors.top: parent.top
    syncView: tableViewId
    //If you want your custom header data, you can use the model property
    //model: ["One", "Two", "Three", "Four", "Five"]

  }

  VerticalHeaderView {
    id: verticalHeaderViewId
    anchors.top: tableViewId.top
    anchors.left: parent.left
    syncView: tableViewId
  }

  TableModel {
    id: tableModelId
    TableModelColumn {
      display: "checked"
    }
    TableModelColumn {
      display: "amount"
    }
    TableModelColumn {
      display: "fruitType"
    }
    TableModelColumn {
      display: "fruitName"
    }
    TableModelColumn {
      display: "fruitPrice"
    }

    // Each row is one type of fruit that can be ordered
    rows: [
      {
        // Each property is one cell/column.
        checked: false,
        amount: 1,
        fruitType: "Apple",
        fruitName: "Granny Smith",
        fruitPrice: 1.50
      },
      {
        checked: true,
        amount: 4,
        fruitType: "Orange",
        fruitName: "Navel",
        fruitPrice: 2.50
      },
      {
        checked: false,
        amount: 1,
        fruitType: "Banana",
        fruitName: "Cavendish",
        fruitPrice: 3.50
      }
    ]
  }

  TableView {
    id: tableViewId
    anchors.left: verticalHeaderViewId.right
    anchors.top: horizontalHeaderViewId.bottom
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    columnSpacing: 1
    rowSpacing: 1
    model: tableModelId
    /*
        delegate: TextInput{
        text: model.display
        padding: 12
        //selectByMouse: true // Not needed in Qt versions new than Qt 6.4
        onAccepted: function(){
        model.display = text
        }
        Rectangle{
        anchors.fill: parent
        color: "#efefef"
        z: -1
        }
        }
        */

    //Use DelegateChooser
    delegate: delegateId
  }

  DelegateChooser {
    id: delegateId
    DelegateChoice {
      column: 0
      delegate: CheckBox {
        required property var model
        checked: model.display
        onToggled: function () {
          model.display = checked;
        }
      }
    }

    DelegateChoice {
      column: 1
      delegate: SpinBox {
        required property var model
        value: model.display
        onValueModified: function () {
          model.display = value;
        }
      }
    }

    DelegateChoice {
      delegate: TextField {
        required property var model
        text: model.display
        implicitWidth: 140
        onAccepted: function () {
          model.display = text;
        }
      }
    }
  }

  Button {
    text: "Show the data"
    anchors.bottom: parent.bottom
    onClicked: function () {
      console.log(tableModelId.data(tableModelId.index(0, 1), "display"));
    }
  }
}
