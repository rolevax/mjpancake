import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../area"

Room {
    showReturnButton: false

    AreaLogin {
        anchors.centerIn: parent
    }

    Connections {
        target: PClient

        onUserChanged: {
            if (PClient.loggedIn) {
                global.pushScene("room/RoomFuncs");
            }
        }
    }
}
