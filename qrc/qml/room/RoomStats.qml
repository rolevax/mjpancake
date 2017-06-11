import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/nettrans.js" as NetTrans
import "../widget"
import "../area"
import "../game"

Room {
    id: room

    Connections {
        target: PClient
    }

    Item {
        anchors.left: parent.left
        anchors.right: girlMenu.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0.05 * parent.width
        anchors.rightMargin: 0.005 * parent.width
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height

        AreaTitle {
            id: title
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        AreaBigStats {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: title.bottom
            anchors.bottom: parent.bottom
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
        currGirlId: -2 // summary
        onCurrGirlIdChanged: {}
        Component.onCompleted: { currGirlIdChanged(); }
    }
}
