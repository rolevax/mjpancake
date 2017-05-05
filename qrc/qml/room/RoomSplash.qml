import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Rectangle {
    signal closed

    anchors.fill: parent
    color: PGlobal.themeBack

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false
        onClicked: {
			closed();
        }
    }

    focus: true
    Keys.onPressed: {
		// press any key to close
        closed();
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

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "喵击任意处开始"
            SequentialAnimation on opacity {
                PropertyAnimation { to: 0.3; duration: 500 }
				PauseAnimation { duration: 200 }
                PropertyAnimation { to: 1.0; duration: 500 }
                loops: Animation.Infinite
                running: true
            }
        }
    }
}
