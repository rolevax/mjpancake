import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../area"
import "../game"

Room {
    id: room

    property bool _playing: false

    backButtonZ: 10
    showReturnButton: !_playing

    Rectangle {
        visible: !_playing
        anchors.centerIn: parent
        color: global.color.back
        height: areaBook.height + 2 * global.size.gap
        width: areaBook.width + 2 * global.size.gap

        Column {
            id: areaBook
            spacing: global.size.space
            anchors.centerIn: parent

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "在线: " + PClient.connCt + " 桌子: -"
            }

            Item { height: global.size.space; width: 1 }

            Repeater {
                model: 2
                delegate:  AreaBookRow {
                    anchors.right: parent.right
                    ruleId: index
                }
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: !_playing
        triggeredOnStart: true
        onTriggered: {
            PClient.lookAround();
        }
    }

    Connections {
        target: PClient

        onTableInitRecved: {
            // historical, useless now, remove someday
            // as RoomGameOnline is pushed when start,
            // this room is unloaded totally then
            _playing = true;
        }
    }
}
