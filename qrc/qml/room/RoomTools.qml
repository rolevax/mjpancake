import QtQuick 2.7
import "../widget"

Room {
    id: room

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Buzzon {
            text: "手役生成器"
            textLength: 8
            onClicked: { global.pushScene("room/RoomGen"); }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "牌形分解器"
            textLength: 8
            onClicked: { global.pushScene("room/RoomParse"); }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
