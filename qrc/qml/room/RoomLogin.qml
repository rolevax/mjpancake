import QtQuick 2.7

Room {
    showReturnButton: false

    MouseArea {
        anchors.fill: parent
        onClicked: {
            global.pushScene("room/RoomMainMenu");
        }
    }
}
