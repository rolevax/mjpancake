import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../area"
import "../game"

Room {
    id: room

    property var girlIds: [ 0, 0, 0, 0 ]
    property var users: [ null, null, null, null ]
    property int tempDealer

    Row {
        id: rowMain
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
            id: areaOp
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Texd {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: rowMain.bottom
        anchors.topMargin: global.size.gap
        text: "凑桌/讨论QQ群 253708512"
    }

    function _closeTable() {
        loader.source = "";
        areaOp.popBookButtons();
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            // need these to enable keyboard and android 'back' key inside table
            room.focus = false;
            loader.focus = true;

            item.table.tileSet = "std";
            item.table.setGirlIds(girlIds);
            item.table.setUsers(users);
            item.table.middle.setDealer(tempDealer, true);
            item.table.closed.connect(_closeTable);

            startTimer.start();
        }
    }

    AreaStage {
        id: areaStage
        users: room.users
        girlIds: room.girlIds
        onReadyClicked: {
            PClient.sendReady();
        }
    }

    AreaChoose {
        id: areaChoose
        users: room.users
        onChosen: {
            PClient.sendChoose(girlIndex);
        }
    }

    Timer {
        id: startTimer
        interval: 17
        onTriggered: {
            loader.item.startOnline(PClient);
            if (areaStage.visible)
                areaStage.showReady = true;
            else
                PClient.sendResume();
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: loader.source == "" && !areaChoose.visible && !areaStage.visible
        triggeredOnStart: true
        onTriggered: {
            PClient.lookAround();
        }
    }

    Connections {
        target: PClient

        onStartIn: {
            room.tempDealer = tempDealer;

            for (var i = 0; i < 4; i++)
                room.users[i] = users[i];
            areaChoose.users = room.users;
            areaChoose.choices = choices;
            areaChoose.splash();
        }

        onChosenIn: {
            room.girlIds = girlIds;
            // somehow variants are not binded... fuck qml
            areaStage.girlIds = room.girlIds;
            areaStage.users = room.users;
            areaChoose.visible = false;
            areaStage.splash();

            loader.source = "../game/Game.qml";
        }

        onResumeIn: {
            loader.source = "../game/Game.qml";
        }

        onRemoteClosed: {
            closed();
        }

        onTableEvent: {
            areaStage.visible = false;
        }
    }

    onClosed: {
        PClient.unbook();
    }

    function _rankPercent(r) {
        if (!PClient.user.Ranks)
            return "----%";
        return ((PClient.user.Ranks[r] / PClient.playCt) * 100).toFixed(1) + "%";
    }
}
