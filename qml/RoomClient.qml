import QtQuick 2.0
import rolevax.sakilogy 1.0
import "widget"

Room {
    id: room

    property bool locked: false

    property var girlIds: [ 0, 0, 0, 0 ]
    property var displayedNames: [ "???", "???", "???", "???" ]
    property int tempDealer

    Column {
        id: opArea
        anchors.centerIn: parent
        spacing: global.size.space

        Texd {
            anchors.horizontalCenter: parent.horizontalAlignment
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            text: "在线：" + PClient.connCt + "      呆萌：" + PClient.idleCt
        }

        Item {  width:1; height: global.size.gap }

        Row {
            spacing: global.size.gap
            Texd {
                text: "71届IH规则（除包杠）"
                font.pixelSize: global.size.middleFont
                anchors.verticalCenter: parent.verticalCenter
            }

            Buzzon {
                id: bookButton
                anchors.verticalCenter: parent.verticalCenter
                textLength: 4
                text: "预约"
                onClicked: {
                    enabled = false;
                    PClient.book();
                }
            }

            Texd {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: global.size.middleFont
                text: PClient.bookCt + ":" + PClient.playCt
            }
        }
    }

    function _closeTable() {
        loader.source = "";
        bookButton.enabled = true;
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
            loader.source = "Game.qml";
        }
    }
}
