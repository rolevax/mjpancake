import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Room {
    id: room

    property int currentRoundId: roundsGombo.currentIndex
    property int currentTurn: -1
    property bool endOfRound: false
    property string tableSeed
    property string roundSeed

    PReplay {
        id: pReplay
    }

    ListView {
        id: listView

        width: parent.width * 0.8
        height: parent.height * 0.8
        anchors.centerIn: parent
        spacing: global.size.space

        delegate: Item {
            width: listView.width
            height: viewButton.height
            Buzzon {
                id: viewButton
                width: listView.width * 0.8
                text: modelData.substring(0, modelData.length - 9)
                onClicked: {
                    pReplay.load(modelData);
                    loader.source = "../game/Game.qml";
                }
            }

            Buzzon {
                width: listView.width * 0.1
                anchors.right: parent.right
                text: "删"
                onClicked: {
                    pReplay.rm(modelData);
                    listView.model = pReplay.ls();
                }
            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            loader.item.table.animEnabled = false;
            loader.item.table.keepOpen = true;

            var meta = pReplay.meta();
            roundsGombo.model = meta.roundNames.map(_roundNameTr);
            loader.item.table.setGirlIds(meta.girlIds);
            tableSeed = meta.seed;

            currentTurn = 1; // show from first draw (dealer's 14th)
            _updateSnap();
        }
    }


    MouseArea {
        property real dragStartX

        anchors.fill: parent
        enabled: replayControl.visible

        onWheel: {
            var dy = wheel.angleDelta.y;
            if (dy !== 0) {
                wheel.accepted = true;
                if (dy < 0) { // scroll down
                    _nextStep();
                } else if (dy > 0) { // scroll up
                    _prevStep();
                }
            }
        }

        onPressed: {
            dragStartX = mouse.x;
        }

        onPositionChanged: { // press and drag
            var stride = width / 20;
            if (mouse.x - dragStartX > stride) { // right stride
                dragStartX = mouseX;
                _nextStep();
            } else if (dragStartX - mouse.x > stride) { // left stride
                dragStartX = mouseX;
                _prevStep();
            }
        }
    }

    Row {
        id: replayControl
        visible: loader.source == Qt.resolvedUrl("../game/Game.qml")
        spacing: global.size.space

        Buzzon {
            text: "已阅"
            smallFont: true
            onClicked: { loader.source = ""; }
        }

        GomboMenu {
            id: roundsGombo
            model: [ "no_round" ]
        }
    }

    Rectangle {
        color: "#99000000"
        visible: replayControl.visible
        width: seedText.width + global.size.gap
        height: seedText.height
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        Texd {
            id: seedText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: room.height / 30
            text: tableSeed + ":" + roundSeed
        }
    }

    Rectangle {
        color: "#99000000"
        visible: replayControl.visible
        width: versionText.width + global.size.gap
        height: versionText.height
        anchors.right: parent.right
        anchors.top: parent.top
        Texd {
            id: versionText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: room.height / 30
            text: global.version + "-" + Qt.platform.os
        }
    }

    Component.onCompleted: {
        listView.model = pReplay.ls();
    }

    onCurrentRoundIdChanged: {
        currentTurn = 1;
        _updateSnap();
    }

    function _nextStep() {
        if (!endOfRound) {
            currentTurn++;
            _updateSnap();
        }
    }

    function _prevStep() {
        if (currentTurn > 1) {
            currentTurn--;
            _updateSnap()
        }
    }

    function _roundNameTr(enStr) {
        var str = enStr;
        str = str.replace("E", "東");
        str = str.replace("S", "南");
        str = str.replace("W", "西");
        str = str.replace("N", "北");
        return str;
    }

    function _updateSnap() {
        var snap = pReplay.look(currentRoundId, currentTurn);
        roundSeed = snap.state;
        endOfRound = snap.endOfRound;
        loader.item.showSnap(snap);
    }
}
