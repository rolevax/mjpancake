import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../area"
import "../widget"
import "../game"
import "../js/girlnames.js" as Names

Room {
    id: room

    property var users: [ null, null, null, null ]

    showReturnButton: false

    Game {
        id: game
        visible: false
        focus: true
        table.onClosed: {
            room.closed();
        }
    }

    AreaChoose {
        id: areaChoose
        anchors.fill: parent
        onChosen: {
            //
            PClient.sendTableChoose(girlIndex);
        }
    }

    AreaStage {
        id: areaStage
        anchors.fill: parent
        users: room.users
        onSeatClicked: {
            PClient.sendTableSeat();
        }
    }

    Connections {
        target: PClient

        onTableSeatRecved: {
            game.startOnline(PClient, girlIds, room.users, tempDealer);
            game.visible = true;
            areaChoose.visible = false;
            areaStage.girlIds = girlIds;
            areaStage.splash();
        }

        onTableEvent: {
            areaStage.visible = false;
        }
    }

    function startChoose(matchResult, choices) {
        room.users = matchResult.Users;
        areaChoose.choices = choices;
        areaChoose.splash();
    }
}


