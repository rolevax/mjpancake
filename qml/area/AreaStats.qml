import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/nettrans.js" as NetTrans
import "../widget"

Column {
    spacing: global.size.space


    Column {
        anchors.horizontalCenter: parent.horizontalCenter

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 1.1 * global.size.middleFont
            text: PClient.user.Username
        }

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: global.size.smallFont
            opacity: 0.8
            text: "ID " + PClient.user.Id
        }
    }

    Texd {
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: global.size.middleFont
        text: NetTrans.level(PClient.user.Level) + " "
              + NetTrans.points(PClient.user.Level, PClient.user.Pt) + " "
              + NetTrans.rating(PClient.user.Rating)
    }

    Item { width:1; height: global.size.gap }

    Texd {
        anchors.horizontalCenter: parent.horizontalCenter
        text: PClient.playCt + " 战"
    }

    Repeater {
        model: 4
        delegate: Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 6 * global.size.defaultFont
            height: global.size.defaultFont

            Texd {
                anchors.left: parent.left
                text: (index + 1) + "位"
            }

            Texd {
                anchors.right: parent.right
                text: _rankPercent(index);
            }
        }
    }
}
