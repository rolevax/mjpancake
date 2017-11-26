import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../area"
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
        visible: names.visible
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
        anchors.fill: names
        enabled: names.visible
        onClicked: {
            names.visible = false;
        }
    }

    AreaLogin {
        id: areaLogin
        visible: !names.visible
        anchors.centerIn: parent
    }

    Texd {
        visible: areaLogin.visible
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: global.size.space
        text: "单机模式"
        color: "blue"
        font.underline: true

        MouseArea {
            anchors.fill: parent
            onClicked: {
                PClient.logout();
                global.pushScene("room/RoomMainMenu");
            }
        }
    }

    Connections {
        target: PClient

        onUserChanged: {
            if (PClient.loggedIn)
                global.pushScene("room/RoomMainMenu");
        }
    }
}
