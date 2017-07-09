import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Item {
    id: room

    signal closed

    anchors.fill: parent

    MouseArea {
        anchors.fill: parent
        onClicked: { Qt.quit(); }
    }

    Column {
        anchors.centerIn: parent
        spacing: global.size.gap

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: 1.2 * global.size.middleFont
            text: "松饼麻雀制作中途版\n" + PGlobal.version
        }

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
			horizontalAlignment: Text.AlignHCenter
            text: "制作人员\nrolevax + 招人中"
        }
    }

    Texd {
        id: horseText
        text: "馬"
        font.pixelSize: 0.15 * room.height

        SequentialAnimation on x {
            PropertyAnimation { to: room.width - horseText.width; duration: 700 }
            PropertyAnimation { to: 0; duration: 700 }
            loops: Animation.Infinite
            running: true
        }
        SequentialAnimation on y {
            PropertyAnimation { to: 0.5 * room.height - horseText.height; duration: 200 }
            PropertyAnimation { to: 0.5 * room.height; duration: 200 }
            loops: Animation.Infinite
            running: true
        }
    }
}
