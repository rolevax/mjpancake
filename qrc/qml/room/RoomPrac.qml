import QtQuick 2.7
import "../widget"

Room {
    id: room

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Buzzon {
            text: "AI战"
            textLength: 8
            onClicked: { global.pushScene("room/RoomGameFree"); }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "牌效练习"
            textLength: 8
            onClicked: { global.pushScene("room/RoomEff"); }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "国标练习"
            textLength: 8
            onClicked: { global.pushScene("room/RoomEffGB"); }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
