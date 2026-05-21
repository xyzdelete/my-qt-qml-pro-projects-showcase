pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow  {
  id: rootId
  visible: true
  Material.foreground: "black"
  width: 1280
  height: 720

    FootBallTeam {
        id : team1
        title: "Rayon Sports"
        coatch: "Coatch Name"
        captain: Striker{
            name: "Captain"
            position: "Middle Field"
            playing: true
        }

        players: [
            Defender{
                name: "Player1"
                position: "Middle Field"
                playing: true
            },
            Striker{
                name: "Player2"
                position: "Middle Field"
                playing: true
            },
            Defender{
                name: "Player3"
                position: "Middle Field"
                playing: true
            },
            Striker{
                name : "Daniel"
                position: "None"
                playing: false
            }
        ]
    }

    ListView {
        anchors.fill: parent
        model : team1.players
        delegate: Rectangle{
          required property var modelData
          id: delegateId
            width: parent.width
            height: 50
            border.width: 1
            border.color: "yellowgreen"
            color: "beige"

            Text {
                anchors.centerIn: parent
                text : delegateId.modelData.name
                font.pointSize: 20
            }
        }
    }

    Component.onCompleted: {
        console.log("We have :" + team1.players.length + " players in the team "+ team1.title)
    }
}
