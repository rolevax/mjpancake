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
    property string replayId: ""

    property bool _loading: false

    PReplay {
        id: pReplay

        onOnlineReplayListReady: {
            onlineListView.model = ids;
        }

        onOnlineReplayReady: {
            loader.source = "../game/Game.qml";
        }
    }

    Texd {
        font.pixelSize: global.size.middleFont
        text: "段位牌谱"
        anchors.bottom: onlineListView.top
        anchors.bottomMargin: global.size.space
        anchors.horizontalCenter: onlineListView.horizontalCenter
    }

    Texd {
        font.pixelSize: global.size.middleFont
        text: "单机牌谱"
        anchors.bottom: localListView.top
        anchors.bottomMargin: global.size.space
        anchors.horizontalCenter: localListView.horizontalCenter
    }

    LisdView {
        id: onlineListView

        width: parent.width * 0.3
        height: parent.height * 0.8 - replayIdInput.height - global.size.space
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.05
        anchors.top: localListView.top

        model: []
        delegate: Buzzon {
            width: parent.width
            text: modelData
            enabled: !_loading
            onClicked: { _fetchOnline(modelData); }
        }
    }

    TexdInput {
        id: replayIdInput
        width: onlineListView.width
        anchors.left: onlineListView.left
        anchors.top: onlineListView.bottom
        anchors.topMargin: global.size.space
        hintText: "通过编号查看他人牌谱"
        number: true
        enabled: !_loading
        onAccepted: {
            _fetchOnline(text);
            text = "";
            removeFocus();
        }
    }

    LisdView {
        id: localListView

        width: parent.width * 0.55
        height: parent.height * 0.8
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.05
        anchors.verticalCenter: parent.verticalCenter
        spacing: global.size.space

        delegate: Item {
            width: parent.width
            height: viewButton.height

            Buzzon {
                id: viewButton
                width: parent.width * 0.8
                enabled: !_loading
                text: modelData.substring(0, modelData.length - 9)
                onClicked: {
                    replayId = "";
                    pReplay.load(modelData);
                    loader.source = "../game/Game.qml";
                }
            }

            Buzzon {
                width: parent.width * 0.15
                anchors.right: parent.right
                enabled: !_loading
                text: "删"
                onClicked: {
                    pReplay.rm(modelData);
                    localListView.model = pReplay.ls();
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
            if (meta.users)
                loader.item.table.setUsers(meta.users);

            currentTurn = 1; // show from first draw (dealer's 14th)
            _updateSnap();
            _loading = false;
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
            var stride = width / 25;
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

        GomboMenu {
            id: persGombo
            model: [ "视角0", "视角1", "视角2", "视角3" ]
            onActivated: {
                if (replayControl.visible) {
                    var meta = pReplay.meta();
                    for (var i = 0; i < currentIndex; i++) {
                        var temp;
                        temp = meta.girlIds.shift();
                        meta.girlIds.push(temp);
                        if (meta.users) {
                            temp = meta.users.shift();
                            meta.users.push(temp);
                        }
                    }

                    loader.item.table.setGirlIds(meta.girlIds);
                    if (meta.users)
                        loader.item.table.setUsers(meta.users);

                    _updateSnap();
                }
            }
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
            text: "玄学码:" + tableSeed + "/" + roundSeed +
                  (replayId === "" ? "" : " 牌谱编号:" + replayId)
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

    Rectangle {
        color: "#99000000"
        visible: _loading
        width: parent.width
        height: 0.5 * parent.height
        anchors.centerIn: parent
        Texd {
            id: loadingText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 0.1 * parent.height
            text: "正在从茫茫零食堆里捞出牌谱……"
        }
    }

    Component.onCompleted: {
        localListView.model = pReplay.ls();
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
        loader.item.showSnap(snap, persGombo.currentIndex);
    }

    function _fetchOnline(id) {
        replayId = id;
        _loading = true;
        pReplay.fetch(id);
    }
}
