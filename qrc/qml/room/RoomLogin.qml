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

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "[贡献者]"
            font.pixelSize: global.size.middleFont
        }

        Repeater {
            model: [
                "Yoarkisess",
                "百度没留电话的小喵",
                "花鹿水",
                "九月",
                "临海小红帽"
            ]

            delegate:  Texd {
                text: modelData
                font.pixelSize: global.size.middleFont
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
