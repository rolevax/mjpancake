import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Room {
    showReturnButton: false

    Row {
        anchors.centerIn: parent
        spacing: global.size.space

        Buxxon {
            image: "/pic/icon/book.png"
            text: "剧情(未开放)"
            textLength: 8
            enabled: false
        }

        Repeater {
            model: [
                { text: "对战", load: "Choose" },
                { text: "工具", load: "Tools" },
                { text: "设置", load: "Settings" }
            ]

            delegate: Buxxon {
                image: "/pic/icon/book.png"
                text: modelData.text
                textLength: 8
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
