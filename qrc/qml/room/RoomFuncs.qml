import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Room {
    showReturnButton: false

    Row {
        anchors.centerIn: parent
        spacing: global.size.space

        Repeater {
            model: [
                { text: "剧情", enabled: false, load: "" },
                { text: "挑战赛", enabled: true, load: "Choose" },
                { text: "团体战", enabled: false, load: "" },
                { text: "工具", enabled: true, load: "Tools" },
                { text: "设置", enabled: true, load: "Settings" }
            ]

            delegate: Buxxon {
                image: "/pic/icon/book.png"
                text: modelData.text
                textLength: 8
                enabled: modelData.enabled
                onClicked: {
                    global.pushScene("room/Room" + modelData.load);
                }
            }
        }

        Buxxon {
            image: "/pic/icon/book.png"
            text: "骑马"
            textLength: 8
            onClicked: { Qt.quit(); }
        }
    }
}
