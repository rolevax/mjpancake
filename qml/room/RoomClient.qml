import QtQuick 2.0
import rolevax.sakilogy 1.0
import "../js/girlnames.js" as Names
import "../widget"
import "../area"
import "../game"

Room {
    id: room

    property var girlIds: [ 0, 0, 0, 0 ]
    property var displayedNames: [ "???", "???", "???", "???" ]
    property var users: [ null, null, null, null ]
    property int tempDealer

    Row {
        anchors.centerIn: parent
        spacing: 2 * global.size.gap

        AreaStats {
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 1
            height: parent.height
            color: PGlobal.themeText
            opacity: 0.5
        }

        AreaOp {
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    function _closeTable() {
        loader.source = "";
        bookS71.booking = false;
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            // need these to enable keyboard and android 'back' key inside table
            room.focus = false;
            loader.focus = true;

            item.table.tileSet = "std";
            item.table.setNames(displayedNames);
            item.table.setUsers(users);
            item.table.middle.setDealer(tempDealer, true);
            item.table.closed.connect(_closeTable);

            startTimer.start();
        }
    }

    AreaStage {
        id: areaStage
        users: room.users
        names: room.displayedNames
        onReadyClicked: {
            PClient.sendReady();
        }
    }

    Timer {
        id: startTimer
        interval: 17
        onTriggered: {
            loader.item.startOnline(PClient);
            areaStage.showReady = true;
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: loader.source == ""
        triggeredOnStart: true
        onTriggered: {
            PClient.lookAround();
        }
    }

    Connections {
        target: PClient
        onStartIn: {
            room.tempDealer = tempDealer;
            room.girlIds = girlIds;
            for (var i = 0; i < 4; i++) {
                room.displayedNames[i] = Names.names[girlIds[i]];
                room.users[i] = users[i];
            }

            // somehow variants are not binded... fuck qml
            areaStage.names = room.displayedNames;
            areaStage.users = room.users;
            areaStage.splash();

            loader.source = "../game/Game.qml";
        }

        onRemoteClosed: {
            closed();
        }

        onPointsChanged: {
            areaStage.visible = false;
        }
    }

    onClosed: {
        PClient.unbook();
    }

    function _rankPercent(r) {
        return ((PClient.user.Ranks[r] / PClient.playCt) * 100).toFixed(1) + "%";
    }
}
