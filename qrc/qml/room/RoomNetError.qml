import QtQuick 2.7
import "../widget"

Room {
    showReturnButton: false

    Rectangle {
        color: global.color.back
        anchors.fill: text
        anchors.margins: -global.size.gap
    }

    Texd {
        id: text
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        text: "因网络问题，封面公告/制作人员名单加载失败\n单机功能仍可正常使用"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            global.pushScene("room/RoomMainMenu");
        }
    }
}
