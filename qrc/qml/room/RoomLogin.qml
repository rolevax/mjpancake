import QtQuick 2.7
import "../widget"

Room {
    readonly property var _contributors: [
        "ethan",
        "皋月",
        "如画江山",
        "sakisan",
        "喵打",
        "TSD",
        "Paper",
        "chaseyun",
        "银",
        "宅炮",
        "Mikyu",
        "花鹿水",
        "白夜旬",
        "Yoarkisess",
        "九月",
        "临海小红帽"
    ]

    showReturnButton: false

    Rectangle {
        color: global.color.back
        anchors.fill: names
        anchors.margins: -global.size.gap
    }

    Column {
        id: names
        anchors.centerIn: parent
        spacing: global.size.gap

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "贡 献 者\n（截至版本发布时）"
            font.pixelSize: global.size.middleFont
            horizontalAlignment: Text.AlignHCenter
        }

        Grid {
            columns: 3
            spacing: global.size.space
            Repeater {
                model: _contributors
                delegate:  Texd {
                    text: modelData
                    width: 8 * global.size.defaultFont
                    font.pixelSize: global.size.middleFont
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            global.pushScene("room/RoomMainMenu");
        }
    }
}
