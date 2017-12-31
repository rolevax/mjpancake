import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Room {
    id: room

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Buzzon {
            text: "背景"
            textLength: 8
            enabled: PGlobal.official
            onClicked: {
                global.pushScene("room/RoomBackground");
            }
        }

        Buzzon {
            text: "头像"
            textLength: 8
            onClicked: {
                global.pushScene("room/RoomPhoto");
            }
        }

        Buzzon {
            text: PGlobal.mute ? "音效 X" : "音效 O"
            textLength: 8
            onClicked: {
                PGlobal.mute = !PGlobal.mute;
            }
        }
    }

    onClosed: {
        PGlobal.save();
    }
}
