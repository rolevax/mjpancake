import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Room {
    showReturnButton: false

    Flow {
        anchors.centerIn: parent
        spacing: global.size.space
        width: 4 * normal.width + 3 * global.size.space

        Buxxon {
            width: 2 * normal.width + global.size.space
            textLength: 7
            text: "单人模式"
            onClicked: {
                global.pushScene("room/RoomGameFree");
            }
        }

        Repeater {
            model: [
                { text: "麻将部备品", load: "Tools" },
                { text: "设置", load: "Settings" },
                { text: "联机", load: "Client" },
                { text: "人物编辑", load: "EditList" },
                { text: "人物下载", load: "CharDown" }
            ]

            delegate: Buxxon {
                text: modelData.text
                textLength: 7
                enabled: index !== 2 || PClient.loggedIn
                onClicked: {
                    global.pushScene("room/Room" + modelData.load);
                }
            }
        }

        Buxxon {
            id: normal
            textLength: 7
            text: "社区主站"
            onClicked: {
                Qt.openUrlExternally("https://mjpancake.github.io/");
            }
        }
    }
}
