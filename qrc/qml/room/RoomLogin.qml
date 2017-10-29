import QtQuick 2.7
import "../widget"

Room {
    showReturnButton: false

    Rectangle {
        color: global.color.back
        anchors.fill: names
        anchors.margins: -global.size.gap
    }

    Column {
        id: names
        anchors.centerIn: parent
        spacing: global.size.space

        Repeater {
            model: [
                { "role": "开发", "names": [ "rolevax" ] },
                {
                    "role": "参谋/校正",
                    "names": [
                        "Yoarkisess",
                        "百度没留电话的小喵",
                        "花鹿水",
                        "九月",
                        "临海小红帽"
                    ]
                }
            ]

            delegate: Column {
                anchors.horizontalCenter: parent.horizontalCenter

                Texd {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "[" + modelData.role + "]"
                    font.pixelSize: global.size.middleFont
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: global.size.space

                    Repeater {
                        model: modelData.names
                        Texd {
                            text: modelData
                            font.pixelSize: global.size.middleFont
                        }
                    }
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
