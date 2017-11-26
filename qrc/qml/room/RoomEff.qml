import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/spell.js" as Spell
import "../widget"
import "../game"

Room {
    id: room

    // small tile width, height
    property real tw: height / 20
    property real th: 1.35 * tw

    // big tile width and height
    property real _prevTwb
    property real twb: height / 17
    property real thb: 1.35 * twb

    property int _round: 0
    property int _roundLimit: 10

    property var _gains: []
    property var _finishTurns: []

    backButtonZ: 1

    PEff {
        id: pEff

        onDealt: {
            function cb() {
                pc.deal(init);
                doraIndic.doraIndic = [ indic ];
            }

            animBuf.push({ callback: cb, duration: 1300 });
        }

        onDrawn: {
            function cb() {
                remainText.text--;
                pc.draw(tile);
            }

            // prelude to wait the spin-out anim done
            animBuf.push({ callback: cb, duration: 100, prelude: 200 });
        }

        onAnkaned: {
            function cb() {
                pc.bark(bark, spin);
                if (pEff.kandora) {
                    doraIndic.doraIndic.push(newIndic);
                    doraIndic.doraIndicChanged();
                }
            }

            animBuf.push({ callback: cb, duration: 300 });
        }

        onActivated: {
            function cb() {
                pc.activate(actions);
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onAutoSpin: {
            function cb() {
                river.model.append({ modelTileStr: pc.drawnStr });
                pc.fixSyncError("");
            }

            animBuf.push({ callback: cb, duration: 200 });
        }

        onExhausted: {
            function cb() {
                formText.text = "流局";
                rectResult.visible = true;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onFinished: {
            function cb() {
                _gains.push(gain);
                _finishTurns.push(turn);
                formText.text = turn + "巡\n" +
                        Spell.spell(form.spell) + "\n" +
                        Spell.charge(form.charge);
                rectResult.visible = true;
                uradoraIndic.doraIndic = urids;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }
    }

    AnimadionBuffer { id: animBuf }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: global.size.space
        spacing: global.size.gap

        DoraIndic {
            id: doraIndic
            visible: rectRemain.visible || rectAnswer.visible || rectResult.visible
            tw: room.tw
        }

        DoraIndic {
            id: uradoraIndic
            visible: rectResult.visible
            tw: room.tw
        }
    }

    PinchArea {
        anchors.fill: parent

        onPinchStarted: {
            room._prevTwb = room.twb;
        }

        onPinchUpdated: {
            var next = pinch.scale * room._prevTwb;
            if (next < room.tw || next > room.height * 1.6 / 14)
                return;
            room.twb = next;
        }
    }

    Column {
        visible: _round === 0 && !statRect.visible
        anchors.centerIn: parent
        spacing: global.size.gap

        Row {
            spacing: global.size.space

            GomboToggle {
                model: ["里宝牌 X", "里宝牌 O"]
                onActivated: { pEff.uradora = index }
                Component.onCompleted: { currentIndex = pEff.uradora; }
            }

            GomboToggle {
                model: ["杠宝牌 X", "杠宝牌 O"]
                onActivated: { pEff.kandora = index }
                Component.onCompleted: { currentIndex = pEff.kandora; }
            }

            GomboToggle {
                model: [ "赤0", "赤3", "赤4" ]
                onActivated: { pEff.akadora = index }
                Component.onCompleted: { currentIndex = pEff.akadora; }
            }

            GomboToggle {
                model: ["一发 X", "一发 O"]
                onActivated: { pEff.ippatsu = index }
                Component.onCompleted: { currentIndex = pEff.ippatsu; }
            }
        }

        Texd {
            font.pixelSize: global.size.middleFont
            text: "场风东 自风南"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "开始"
            onClicked: {
                _round = 0;
                _gains = [];
                _finishTurns = [];
                _nextRound();
            }
        }
    }

    Column {
        id: rectRemain
        visible: _round > 0 && !rectResult.visible && !statRect.visible && !rectAnswer.visible
        spacing: global.size.space
        anchors.centerIn: parent

        Texd {
            font.pixelSize: global.size.middleFont
            text: _round + " / " + _roundLimit
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Texd {
            id: remainText
            font.pixelSize: 0.08 * room.height
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "求解"
            onClicked: {
                repAnswer.model = pEff.answer();
                rectAnswer.visible = true;
            }
        }
    }

    Column {
        id: rectResult
        visible: false
        anchors.centerIn: parent
        spacing: global.size.gap

        Texd {
            id: formText
            font.pixelSize: 1.3 * global.size.middleFont
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Buzzon {
            anchors.horizontalCenter: parent.horizontalCenter
            text: ">"
            textLength: 6
            onClicked: {
                rectResult.visible = false;
                _nextRound();
            }
        }
    }

    Column {
        id: statRect
        anchors.centerIn: parent
        visible: false
        spacing: global.size.gap

        Row {
            spacing: global.size.gap
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                spacing: global.size.space

                Repeater {
                    model: [
                        "和了率",
                        "平均和了巡目",
                        "平均和了点数"
                    ]
                    delegate: Texd {
                        font.pixelSize: global.size.middleFont
                        text: modelData
                    }
                }
            }

            Column {
                spacing: global.size.space
                Repeater {
                    id: repStat
                    model: 3
                    delegate: Texd {
                        font.pixelSize: global.size.middleFont
                        anchors.right: parent.right
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        Buzzon {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "OK"
            textLength: 4
            onClicked: {
                statRect.visible = false;
                pc.clear();
                river.model.clear();
            }
        }
    }

    Rectangle {
        visible: rectAnswer.visible
        anchors.fill: rectAnswer
        anchors.margins: -global.size.gap
        color: global.color.back
    }

    Column {
        id: rectAnswer
        visible: false
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -1 * th
        spacing: global.size.space

        Repeater {
            id: repAnswer
            delegate: Row {
                spacing: global.size.space

                Texd {
                    width: 3 * font.pixelSize
                    font.pixelSize: global.size.middleFont
                    text: "打" + Spell.logtr(modelData.out)
                }

                Texd {
                    width: 3 * font.pixelSize
                    font.pixelSize: global.size.middleFont
                    text: modelData.remain + "张"
                }

                Texd {
                    font.pixelSize: global.size.middleFont
                    text: Spell.logtr(modelData.waits)
                }
            }
        }
    }

    GridView {
        id: river
        y: pc.y - 1.2 * th
        anchors.horizontalCenter: parent.horizontalCenter
        width: count * tw
        height: room.th
        cellWidth: tw
        cellHeight: th
        model: ListModel { }
        delegate: Tile {
            tileWidth: tw
            tileStr: modelTileStr
        }
    }

    PlayerControl {
        id: pc
        animEnabled: true
        backColor: PGlobal.backColors[0]
        tw: room.tw
        twb: room.twb
        x: (room.width - 13 * twb) / 2;
        y: room.height - room.thb - 0.02 * room.height;
        z: 2
        width: (room.width + 13 * twb) / 2;
        height: room.thb

        onActionTriggered: {
            rectAnswer.visible = false;
            pc.deactivate();
            if (actStr === "SWAP_OUT")
                river.model.append({ modelTileStr: actTile });
            else if (actStr === "SPIN_OUT")
                river.model.append({ modelTileStr: pc.drawnStr });
            pEff.action(actStr, actArg, actTile);
        }
    }

    function _nextRound() {
        if (_round++ < _roundLimit) {
            pc.clear();
            pEff.deal();
            river.model.clear();
            remainText.text = 27;
        } else {
            _round = 0;
            var ct = _gains.length;
            var rate = ((ct / _roundLimit) * 100).toFixed(1) + "%";
            var avgTurn = (_finishTurns.reduce(function(s,a){return s+a;}, 0) / ct).toFixed(1);
            var avgPoint = (_gains.reduce(function(s,a){return s+a;}, 0) / ct).toFixed(1);
            repStat.itemAt(0).text = rate;
            repStat.itemAt(1).text = avgTurn;
            repStat.itemAt(2).text = avgPoint;
            statRect.visible = true;
        }
    }
}
