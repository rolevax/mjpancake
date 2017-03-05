import QtQuick 2.7
import "../widget"

Room {
    id: room

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Buzzon {
            text: "牌谱"
            textLength: 8
            onClicked: { loader.source = "RoomReplay.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "牌型生成"
            textLength: 8
            onClicked: { loader.source = "RoomGen.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            room.focus = false;
            loader.focus = true;
            item.closed.connect(closeRoom);
        }
    }

    function closeRoom() {
        loader.source = "";
    }
}
