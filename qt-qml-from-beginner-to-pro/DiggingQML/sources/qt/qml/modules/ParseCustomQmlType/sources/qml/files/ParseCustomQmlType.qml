pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls

ApplicationWindow {
  id: root
  objectName: "ApplicationWindow"
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

  FootballTeam {
    id: team1
    title: "Rayon Sports"
    coatch: "Raul Shungu"
    captain: Player {
      name: "Muti Johnson"
      playing: false
      position: "Middle Field"
    }
    players: [
      Player {
        name: "Player One"
        playing: true
        position: "Position One"
      },
      Player {
        name: "Player Two"
        playing: true
        position: "Position Two"
      },
      Player {
        name: "Player Eleven"
        playing: true
        position: "Player Eleven"
      },
      Player {
        name: "Player Twelve"
        playing: true
        position: "Player Twelve"
      },
      Player {
        name: "Player Thirteen"
        playing: false
        position: "Player Thirteen"
      }
    ]
  }
}
