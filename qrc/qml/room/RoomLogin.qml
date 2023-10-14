import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../area"
import "../widget"

Room {
    readonly property var _contributors: [
        "汐羽", "xmt", "如画江山",
        "Once", "TerryHu", "ethan",
        "Lhtie", "皋月", "karkimira",
        "喵打", "TSD", "sakisan",
        "瑞原 はやり", "Mikyu", "银",
        "Paper", "chaseyun", "宅炮",
        "tianmidai123", "迹落无言", "花鹿水",
        "苟利国家生死以", "大七星石户之霞", "中东自爆英灵",
        "白夜旬", "Yoarkisess", "九月",
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
            id: titleText
            visible: PGlobal.official
            anchors.horizontalCenter: parent.horizontalCenter
            text: "贡 献 者\n（截至版本发布时）"
            horizontalAlignment: Text.AlignHCenter
        }

        Grid {
            visible: PGlobal.official
            columns: 3
            spacing: global.size.space
            Repeater {
                model: _contributors
                delegate:  Texd {
                    text: modelData
                    width: titleText.width
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Texd {
            visible: !PGlobal.official
            anchors.horizontalCenter: parent.horizontalCenter
            text: "此版本并非由喵打发布\n" +
                  "遇到任何问题请找上传这个文件的人"
            font.pixelSize: global.size.middleFont
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        anchors.fill: names
        enabled: names.visible
        onClicked: {
            names.visible = false;

            // hide online features, directly start offline mode
            PClient.logout();
            global.pushScene("room/RoomMainMenu");
        }
    }

    AreaLogin {
        id: areaLogin
        visible: PGlobal.official && !names.visible
        anchors.centerIn: parent
    }

    Texd {
        visible: !names.visible
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

        function onUserChanged(resume) {
            // cannot directly find by 'global' after pushed scene somehow
            var globalRef = global;

            if (PClient.loggedIn) {
                PGlobal.save(); // save username/password
                global.pushScene("room/RoomMainMenu");
            }

            if (resume) {
                globalRef.pushScene("room/RoomGameOnline", function(item) {
                    item.startResume();
                });
            }
        }
    }
}
