import QtQuick 2.7
import "../widget"

Room {
    id: room

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Repeater  {
            model: [
                { text: "牌谱", room: "Replay" },
                { text: "牌效练习", room: "Eff" },
                { text: "手役生成器", room: "Gen" },
                { text: "牌形分解器", room: "Parse" },
            ]

            delegate: Buzzon {
                text: modelData.text
                textLength: 8
                onClicked: { global.pushScene("room/Room" + modelData.room); }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
