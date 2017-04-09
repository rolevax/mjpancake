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

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 1 * global.size.gap
        spacing: global.size.gap

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
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
            horizontalAlignment: Text.AlignHCenter
            text: "凑桌/讨论QQ群 253708512\n" +
                  "目前整体人少，凑桌基本靠群\n" +
                  "约桌时间基本集中在晚上或周末"
        }
    }

    function _closeTable() {
        loader.source = "";
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

    function handleStartIn(tempDealer, users, choices) {
        PClient.unbook(); // just pop book buttons

        room.tempDealer = tempDealer;

        for (var i = 0; i < 4; i++)
            room.users[i] = users[i];
        areaChoose.users = room.users;
        areaChoose.choices = choices;
        areaChoose.splash();
    }
}
