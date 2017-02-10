import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Row {
    property string bookType
    property bool booking: false

    property var _ruleNames: {
       "S71": "东南 IH71",
       "S71": "东南 IH71",
       "S71": "东南 IH71",
       "S71": "东南 IH71",
    }

    spacing: global.size.gap

    Texd {
        text: _ruleNames[bookType.substring(1)]
        font.pixelSize: global.size.middleFont
        anchors.verticalCenter: parent.verticalCenter
    }

    Buzzon {
        id: bookButton
        enabled: !booking && PClient.books[bookType].Bookable
        anchors.verticalCenter: parent.verticalCenter
        textLength: 4
        text: booking ? "待齐" : "预约"
        onClicked: {
            booking = true;
            PClient.book(bookType);
        }
    }

    Texd {
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: global.size.middleFont
        text: PClient.books[bookType].Book + ":" + PClient.books[bookType].Play
    }
}
