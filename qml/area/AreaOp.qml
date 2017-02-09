import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Column {
    id: opArea
    spacing: global.size.space

    Texd {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "在线：" + PClient.connCt
    }

    Item { width:1; height: global.size.gap }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: global.size.space

        Buzzon {
            id: dButton
            text: "应援"
            onClicked: {
                selectBar.x = x;
                selectBar.width = width;
                bookS71.bookType = "DS71";
            }
        }

        Buzzon {
            text: "替补"
            onClicked: {
                selectBar.x = x;
                selectBar.width = width;
                bookS71.bookType = "CS71";
            }
        }

        Buzzon {
            text: "正选"
            onClicked: {
                selectBar.x = x;
                selectBar.width = width;
                bookS71.bookType = "BS71";
            }
        }

        Buzzon {
            text: "ＡＣＥ"
            onClicked: {
                selectBar.x = x;
                selectBar.width = width;
                bookS71.bookType = "AS71";
            }
        }
    }

    Rectangle {
        id: selectBar
        width: dButton.width
        radius: 0.5 * height
        height: 0.15 * dButton.height
        color: PGlobal.themeText
        opacity: 0.5

        Behavior on x {
            PropertyAnimation {
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }
    }

    Item { width:1; height: global.size.gap }

    AreaBookRow {
        id: bookS71
        anchors.horizontalCenter: parent.horizontalCenter
        bookType: "DS71"
    }
}
