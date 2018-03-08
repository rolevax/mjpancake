import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../game"

Room {
    id: room

    property int currentRoundId: roundsGombo.currentIndex
    property int currentTurn: -1
    property bool endOfRound: false
    property string tableSeed
    property string roundSeed
    property string replayId: ""

    property bool _loading: false

    showReturnButton: !game.visible

    PReplay {
        id: pReplay

        onLoaded: {
            _showGame();
        }

        onOnlineReplayListReady: {
            onlineListView.model = ids;
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: global.size.gap
        anchors.bottom: replayIdInput.top
        anchors.bottomMargin: global.size.space

        spacing: global.size.gap

        LisdView {
            id: localListView

            visible: !game.visible
            spacing: global.size.space
            width: 0.4 * room.width
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            model: pReplay.ls()
            delegate: Item {
                width: parent.width
                height: buttonDelegate.height

                Buzzon {
                    id: buttonDelegate
                    width: 0.85 * parent.width
                    text: modelData
                    enabled: !_loading
                    onClicked: {
                        pReplay.load(modelData);
                    }
                }

                Buzzon {
                    anchors.right: parent.right
                    width: 0.13 * parent.width
                    text: "删"
                    enabled: !_loading
                    onClicked: {
                        pReplay.rm(modelData);
                        localListView.model = pReplay.ls();
                    }
                }
            }
        }

        LisdView {
            id: onlineListView

            visible: !game.visible && PClient.loggedIn
            spacing: global.size.space
            width: 0.4 * room.width
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            delegate:  Buzzon {
                id: buttonDelegate
                width: 0.85 * parent.width
                text: modelData
                enabled: !_loading
                onClicked: {
                    _fetchOnline(modelData)
                }
            }
        }
    }

    TexdInput {
        id: replayIdInput
        visible: !game.visible && PClient.loggedIn
        width: 12 * global.size.middleFont
        anchors.right: parent.right
        anchors.rightMargin: global.size.space
        anchors.bottom: parent.bottom
        anchors.bottomMargin: global.size.space
        hintText: "通过编号查看他人牌谱"
        number: true
        enabled: !_loading
        onAccepted: {
            _fetchOnline(text);
            text = "";
            removeFocus();
        }
    }

    Game {
        id: game
        visible: false
        anchors.fill: parent

        Rectangle {
            color: "#99000000"
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
            width: versionText.width + global.size.gap
            height: versionText.height
            anchors.right: parent.right
            anchors.top: parent.top
            Texd {
                id: versionText
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: room.height / 30
                text: "" + pReplay.loadedLibVersion
            }
        }

        table.onClosed: {
            game.visible = false;
        }
    }

    MouseArea {
        property real dragStartX

        anchors.fill: parent
        enabled: game.visible

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
        visible: game.visible
        spacing: global.size.space

        Buzzon {
            text: "已阅"
            smallFont: true
            onClicked: {
                game.visible = false;
            }
        }

        GomboMenu {
            id: roundsGombo
            model: [ "no_round" ]
        }

        GomboMenu {
            id: persGombo
            model: [ "视角0", "视角1", "视角2", "视角3" ]
            onActivated: {
                if (game.visible) {
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

                    game.table.setGirlIds(meta.girlIds);
                    if (meta.users)
                        game.table.setUsers(meta.users);

                    _updateSnap();
                }
            }
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
            text: "正在打捞牌谱……"
        }
    }

    Dialok {
        id: dialogOpHint
        fontSize: 2 * global.size.middleFont
        text: "左右滑动屏幕，或上下滚动鼠标滚轮以播放牌谱"
    }

    onCurrentRoundIdChanged: {
        currentTurn = 1;
        _updateSnap();
    }

    function _showGame() {
        game.visible = true;
        dialogOpHint.hint = "replay";

        game.table.animEnabled = false;
        game.table.keepOpen = true;

        var meta = pReplay.meta();
        roundsGombo.model = meta.roundNames.map(_roundNameTr);
        game.table.setGirlIds(meta.girlIds);
        tableSeed = meta.seed;
        if (meta.users)
            game.table.setUsers(meta.users);

        currentTurn = 1; // show from first draw (dealer's 14th)
        _updateSnap();
        _loading = false;
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
        game.showSnap(snap, persGombo.currentIndex);
    }

    function _fetchOnline(id) {
        replayId = id;
        _loading = true;
        pReplay.fetch(id);
    }
}
