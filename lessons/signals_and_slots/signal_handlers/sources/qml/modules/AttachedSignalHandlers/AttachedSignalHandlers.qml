import QtQuick

Item {
  Rectangle {
    id: rectId
    width: 200
    height: 200
    color: "green"
  }

  Component.onCompleted: {
    // Load data for use in the UI
    print("Starting up...")
  }
  Component.onDestruction: {
    // Saving data from the UI to the data store
    print("Finishing up...")
  }
}