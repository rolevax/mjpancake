import QtQuick 2.7
import "../widget"

Room {
    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Buzzon {
            text: "AI战"
            textLength: 8
            onClicked: { loader.source = "RoomGameFree.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "牌效"
            textLength: 8
            onClicked: { loader.source = "RoomEff.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "国标"
            textLength: 8
            onClicked: { loader.source = "RoomEffGB.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            item.closed.connect(closeRoom);
        }
    }

    function closeRoom() {
        loader.source = "";
    }

}
