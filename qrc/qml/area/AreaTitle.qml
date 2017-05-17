import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/nettrans.js" as NetTrans
import "../widget"

Row {
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
