import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/nettrans.js" as NetTrans
import "../widget"
import "../area"
import "../game"

Room {
    id: room

    Item {
        anchors.left: parent.left
        anchors.right: girlMenu.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0.05 * parent.width
        anchors.rightMargin: 0.005 * parent.width
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height

        AreaProfile {
            visible: !diagStat.visible
            anchors.fill: parent
            anchors.margins: 0.05 * parent.width
            girlId: girlMenu.currGirlId

            onStatClicked: {
                diagStat.visible = true;
            }

            onEnterClicked: {
                global.pushScene("room/RoomClient");
            }
        }

        AreaBigStats {
            id: diagStat
            visible: false
            anchors.fill: parent
            currIndex: girlMenu.currIndex
        }
    }

    GirlMenu {
        id: girlMenu
        height: 0.8 * room.height
        anchors.right: parent.right
        anchors.rightMargin: 0.05 * parent.width
        anchors.verticalCenter: parent.verticalCenter
        girlIds: PClient.playedGirlIds
        onCurrGirlIdChanged: { global.currGirlId = currGirlId; }
        Component.onCompleted: { currGirlIdChanged(); }
    }
}
