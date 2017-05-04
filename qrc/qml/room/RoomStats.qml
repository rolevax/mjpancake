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

        Row {
            id: title
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: global.size.gap

            Texd {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 1.1 * global.size.middleFont
                text: PClient.user.Username ? PClient.user.Username : ""
            }

            Texd {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: global.size.smallFont
                opacity: 0.8
                text: "UID " + PClient.user.Id
            }

            Texd {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: global.size.middleFont
                text: NetTrans.level(PClient.user.Level) + " "
                      + NetTrans.points(PClient.user.Level, PClient.user.Pt) + " "
                      + NetTrans.rating(PClient.user.Rating)
            }
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
        onCurrGirlIdChanged: {
            // FUCK
        }
        Component.onCompleted: { currGirlIdChanged(); }
    }
}
