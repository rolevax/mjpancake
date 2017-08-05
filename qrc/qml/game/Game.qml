import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

PinchArea {
    id: frame

    signal closed

    property alias table: table

    // 3 * photoGap + 2 * photoHeight == parent.height
    // 4 * photoGap + photoWidth + table.width == parent.width
    property int photoHeight: 0.47 * height
    property int photoWidth: 0.6 * photoHeight
    property int photoGap: 0.02 * height

    anchors.fill: parent

    MouseArea { // right/double-click to pass/tsumokiri
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onDoubleClicked: {
            table.easyPass();
            mouse.accepted = true;
        }

        onClicked: {
            if (mouse.button & Qt.RightButton)
                table.easyPass();

            mouse.accepted = true;
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
        }

        GirlPhoto {
            id: photo3
            width: photoWidth
            height: photoHeight
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: photoGap
            anchors.leftMargin: photoGap
        }

        GirlPhoto {
            id: photo1
            width: photoWidth
            height: photoHeight
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: photoGap
            anchors.rightMargin: photoGap
        }

        GirlPhoto {
            id: photo0
            width: photoWidth
            height: photoHeight
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: photoGap
            anchors.rightMargin: photoGap
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

    Dialok {
        id: dialogOpHint
        fontSize: 2 * global.size.middleFont
        horizontalAlignment: Text.AlignHCenter
        text: "手牌太小 → 通过触屏手势缩放\n" +
              "双击或右击可摸切/跳过"
    }

    Connections {
        target: table
        onClosed: { frame.closed(); }
    }

    onPinchStarted: {
        table.handlePinchStarted();
    }

    onPinchUpdated: {
        table.handlePinchUpdated(pinch.scale);
    }

    onPinchFinished: {
        PGlobal.forceImmersive();
    }

    function startLocal(girlIds, gameRule, tempDealer) {
        dialogOpHint.hint = "op";

        table.reset();
        table.setGirlIds(girlIds);
        table.middle.setDealer(tempDealer, true);

        table.pTable.startLocal(girlIds, gameRule, tempDealer);
    }

    function startPrac(girlId) {
        dialogOpHint.hint = "op";
        table.reset();
        table.setGirlIds([ girlId, -1, -1, -1 ]);
        table.pTable.startPrac(girlId);
    }

    function startOnline(pClient, girlIds, users, tempDealer) {
        dialogOpHint.hint = "op";

        table.reset();
        table.setGirlIds(girlIds);
        table.setUsers(users);
        table.middle.setDealer(tempDealer, true);

        table.pTable.startOnline(pClient);
    }

    function startSample() {
        dialogOpHint.hint = "";
        table.reset();
        table.setGirlIds([ 713315, 713335, 713345, 713325 ]);
        table.pTable.startSample();
    }

    function showSnap(snap, pers) {
        table.showSnap(snap, pers);
    }
}

