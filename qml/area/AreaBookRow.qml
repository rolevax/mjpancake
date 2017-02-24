import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Row {
    property int bookType
    property bool booking: false

    spacing: global.size.gap

    Texd {
        text: "东南 IH71"
        font.pixelSize: global.size.middleFont
        anchors.verticalCenter: parent.verticalCenter
    }

    Buzzon {
        id: bookButton
        enabled: !booking && PClient.books[bookType].Bookable
        anchors.verticalCenter: parent.verticalCenter
        textLength: 4
        text: booking ? "待开" : "预约"
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
