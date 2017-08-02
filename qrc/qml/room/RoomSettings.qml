import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Room {
    id: room

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Buzzon {
            text: "更改牌桌背景"
            textLength: 8
            onClicked: {
                global.pushScene("room/RoomBackground");
            }
        }

        Buzzon {
            text: PGlobal.savePassword ? "保存密码 O" : "保存密码 X"
            textLength: 8
            onClicked: {
                PGlobal.savePassword = !PGlobal.savePassword;
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
