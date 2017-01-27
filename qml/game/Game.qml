import QtQuick 2.0
import "../widget"

Image {
    id: frame

    property alias table: table

    // 3 * photoGap + 2 * photoHeight == parent.height
    // 4 * photoGap + photoWidth + table.width == parent.width
    property int photoHeight: 0.47 * height
    property int photoWidth: 0.6 * photoHeight
    property int photoGap: 0.02 * height

    anchors.fill: parent
    source: "image://impro/user/background"

    MouseArea { // right/double-click to pass/tsumokiri
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onDoubleClicked: {
            table.easyPass();
            mouse.accepted = true;
        }

        onClicked: {
            if (mouse.button & Qt.RightButton) {
                table.easyPass();
                mouse.accepted = true;
            } else {
                mouse.accepted = false;
            }
        }
    }

    Item {
        id: gameBox

        anchors.fill: parent

        GirlPhoto {
            id: photo2
            width: photoWidth
            height: photoHeight
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: photoGap
            anchors.leftMargin: photoGap
            onRivalShotted: {
                table.deactivate();
                table.pTable.action("IRS_RIVAL", 2);
            }
        }

        GirlPhoto {
            id: photo3
            width: photoWidth
            height: photoHeight
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: photoGap
            anchors.leftMargin: photoGap
            onRivalShotted: {
                table.deactivate();
                table.pTable.action("IRS_RIVAL", 3);
            }
        }

        GirlPhoto {
            id: photo1
            width: photoWidth
            height: photoHeight
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: photoGap
            anchors.rightMargin: photoGap
            onRivalShotted: {
                table.deactivate();
                table.pTable.action("IRS_RIVAL", 1);
            }
        }

        GirlPhoto {
            id: photo0
            width: photoWidth
            height: photoHeight
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: photoGap
            anchors.rightMargin: photoGap
            onRivalShotted: {
                table.deactivate();
                table.pTable.action("IRS_RIVAL", 0);
            }
        }

        Table {
            id: table
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            width: parent.width - 4 * photoGap - 2 * photoWidth
            photos: [ photo0, photo1, photo2, photo3 ]
            green: greenWorld
        }

        Rectangle {
            id: greenWorld
            color: "#4400FF00"
            anchors.fill: parent
            visible: false
        }
    }

    function startLocal(girlIds, gameRule, tempDealer) {
        table.pTable.startLocal(girlIds, gameRule, tempDealer);
    }

    function startOnline(pClient) {
        table.pTable.startOnline(pClient);
    }

    function startSample() {
        // one uncahed image client to affect the image provider
        // across the whole program
        frame.cache = false;
        table.setNames(["宮永咲", "加治木ゆみ", "池田華菜", "天江衣"]);
        table.pTable.startSample();
    }

    function showSnap(snap) {
        table.showSnap(snap);
    }
}

