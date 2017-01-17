import QtQuick 2.0
import "widget"

Room {
    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Buzzon {
            text: "常见问题"
            textLength: 8
            onClicked: { loader.source = "RoomHelpFaq.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "操作说明"
            textLength: 8
            onClicked: { loader.source = "RoomHelpOp.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "麻将规则"
            textLength: 8
            onClicked: { loader.source = "RoomHelpRules.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "角色能力"
            textLength: 8
            onClicked: { loader.source = "RoomHelpGirls.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    function closeRoom() {
        loader.source = "";
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            item.closed.connect(closeRoom);
        }
    }
}
