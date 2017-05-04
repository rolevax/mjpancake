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

    property var _fanValues: []
    property var _finishTurns: []

    backButtonZ: 1

    PEffGb {
        id: pEffGb

        onDealt: {
            function cb() {
                pc.deal(init);
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

        onAnganged: {
            function cb() {
                pc.bark(bark, spin);
            }

            animBuf.push({ callback: cb, duration: 500 });
        }

        onActivated: {
            function cb() {
                pc.activate(actions);
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onExhausted: {
            function cb() {
                formText.text = "流局";
                resultRect.visible = true;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onFinished: {
            function cb() {
                _fanValues.push(fan);
                _finishTurns.push(turn);
                formText.text = turn + "巡\n" + Spell.fantr(fans) + "\n" +
                        fan + "番" + (fan < 8 ? "错和" : "");
                resultRect.visible = true;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }
    }

    AnimadionBuffer { id: animBuf }

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

        GomboToggle {
            anchors.horizontalCenter: parent.horizontalCenter
            model: ["能力 X", "能力 O"]
            onActivated: { pEffGb.skill = index }
            Component.onCompleted: { currentIndex = pEffGb.skill; }
        }

        Texd {
            font.pixelSize: global.size.middleFont
            text: "圈风东 门风南\n仅限四面子型、七对型、十三么型"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "开始"
            onClicked: {
                _round = 0;
                _fanValues = [];
                _finishTurns = [];
                _nextRound();
            }
        }
    }

    Column {
        visible: _round > 0 && !resultRect.visible && !statRect.visible
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
    }

    Column {
        id: resultRect
        visible: false
        anchors.centerIn: parent
        spacing: global.size.gap

        Texd {
            id: formText
            width: 0.8 * room.width
            font.pixelSize: 1.3 * global.size.middleFont
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Buzzon {
            anchors.horizontalCenter: parent.horizontalCenter
            text: ">"
            textLength: 6
            onClicked: {
                resultRect.visible = false;
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
                        "和牌率",
                        "平均和牌巡目",
                        "平均和牌番数",
                        "错和率"
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
                    model: 4
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
            pc.deactivate();
            if (actStr === "SWAP_OUT")
                river.model.append({ modelTileStr: actArg });
            else if (actStr === "SPIN_OUT")
                river.model.append({ modelTileStr: pc.drawnStr });
            pEffGb.action(actStr, actArg);
        }
    }

    function _nextRound() {
        if (_round++ < _roundLimit) {
            pc.clear();
            pEffGb.deal();
            river.model.clear();
            remainText.text = 27;
        } else {
            _round = 0;
            var ct = _fanValues.length;
            var rightCt = 0;
            var rightFanSum = 0;
            var rightTurnSum = 0;
            for (var i = 0; i < ct; i++) {
                if (_fanValues[i] >= 8) {
                    rightFanSum += _fanValues[i];
                    rightTurnSum += _finishTurns[i];
                    rightCt++;
                }
            }

            var rightRate = ((rightCt / _roundLimit) * 100).toFixed(1) + "%";
            var avgTurn = (rightTurnSum / rightCt).toFixed(1);
            var avgFan = (rightFanSum / rightCt).toFixed(1);
            var wrongRate = (((ct - rightCt) / ct) * 100).toFixed(1) + "%";
            repStat.itemAt(0).text = rightRate;
            repStat.itemAt(1).text = avgTurn;
            repStat.itemAt(2).text = avgFan;
            repStat.itemAt(3).text = wrongRate;
            statRect.visible = true;
        }
    }
}
