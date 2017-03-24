import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Row {
    property int bookType

    spacing: global.size.gap

    Texd {
        text: "东南 IH71"
        font.pixelSize: global.size.middleFont
        anchors.verticalCenter: parent.verticalCenter
    }

    Buzzon {
        id: bookButton
        enabled: !PClient.bookings[bookType] && PClient.books[bookType].Bookable
        anchors.verticalCenter: parent.verticalCenter
        textLength: 4
        text: PClient.bookings[bookType] ? "待开" : "预约"
        onClicked: { PClient.book(bookType); }
    }

    Texd {
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: global.size.middleFont
        text: PClient.books[bookType].Book + ":" + PClient.books[bookType].Play
    }
}
