import QtQuick 2.0
import rolevax.sakilogy 1.0
import "../js/girlnames.js" as Names
import "../js/nettrans.js" as NetTrans
import "../widget"
import "../area"

Room {
    id: room

    property var girlIds: [ 0, 0, 0, 0 ]
    property var displayedNames: [ "???", "???", "???", "???" ]
    property var users: [ null, null, null, null ]
    property int tempDealer

    Row {
        anchors.centerIn: parent
        spacing: 2 * global.size.gap

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: global.size.space

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: global.size.middleFont
                text: PClient.user.Username
            }

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: global.size.middleFont
                text: NetTrans.level(PClient.user.Level) + " "
                      + NetTrans.points(PClient.user.Level, PClient.user.Pt) + " "
                      + NetTrans.rating(PClient.user.Rating)
            }

            Item { width:1; height: global.size.gap }

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                text: PClient.playCt + " 战"
            }

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "1位 " + _rankPercent(0);
            }

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "2位 " + _rankPercent(1);
            }

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "3位 " + _rankPercent(2);
            }

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "4位 " + _rankPercent(3);
            }
        }

        Rectangle {
            width: 1
            height: parent.height
            color: PGlobal.themeText
            opacity: 0.5
        }

        Column {
            id: opArea
            anchors.verticalCenter: parent.verticalCenter
            spacing: global.size.space

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "在线：" + PClient.connCt
            }

            Item { width:1; height: global.size.gap }

            AreaBookRow { id: bookDS71; bookType: "DS71" }
            AreaBookRow { id: bookCS71; bookType: "CS71" }
            AreaBookRow { id: bookBS71; bookType: "BS71" }
            AreaBookRow { id: bookAS71; bookType: "AS71" }
        }
    }

    function _closeTable() {
        loader.source = "";
        bookDS71.booking = false;
        bookCS71.booking = false;
        bookBS71.booking = false;
        bookAS71.booking = false;
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

    Timer {
        id: startTimer
        interval: 17
        onTriggered: {
            loader.item.startOnline(PClient);
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
            loader.source = "../game/Game.qml";
        }

        onRemoteClosed: {
            closed();
        }
    }

    onClosed: {
        PClient.unbook();
    }

    function _rankPercent(r) {
        return ((PClient.user.Ranks[r] / PClient.playCt) * 100).toFixed(1) + "%";
    }
}
