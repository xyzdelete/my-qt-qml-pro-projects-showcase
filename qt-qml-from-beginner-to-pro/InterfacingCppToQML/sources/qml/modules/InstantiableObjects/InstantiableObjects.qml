pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.qmlmodels
import QtQuick.Dialogs
import QtCore
import QtQuick.LocalStorage
//import InstantiableObject
import instantiable.object.movie

ApplicationWindow {
  id: rootId
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  //Object created on the QML side
  Movie {
    id: movieId
    title: "Titanic"
    mainCharacter: "Leonardo D"
  }

  Button {
    text: "Invoke created object"
    onClicked: {
      movieId.title = "Fast and Furious";
      movieId.mainCharacter = "Vin Diesel";

      console.log("New " + movieId.title + " , " + movieId.mainCharacter);
    }
  }
}
