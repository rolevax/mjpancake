import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/spell.js" as Spell
import "../widget"
import "../game"

Room {
    id: room

    // small tile width, height
    property int tw: height / 20
    property int th: 1.35 * tw

    // big tile width and height
    property int twb: height / 13
    property int thb: 1.35 * twb

    property int _round: 0
    property int _roundLimit: 10

    property var _gains: []
    property var _finishTurns: []

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
                _gains.push(gain);
                _finishTurns.push(turn);
                formText.text = turn + "巡\n" +
                        Spell.spell(form.spell) + "\n" +
                        Spell.charge(form.charge);
                resultRect.visible = true;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }
    }

    AnimadionBuffer { id: animBuf }

    Column {
        visible: _round === 0 && !statRect.visible
        anchors.centerIn: parent
        spacing: global.size.gap

        Texd {
            font.pixelSize: global.size.middleFont
            text: "圈风东 自风南\n仅限四面子型、七对子型、十三么型"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "开始"
            onClicked: {
                _nextRound();
            }
        }
    }

    Column {
        visible: _round > 0 && !resultRect.visible && !statRect.visible && !rectAnswer.visible
        spacing: global.size.space
        anchors.centerIn: parent

        Texd {
            font.pixelSize: global.size.middleFont
            text: _round + " / " + _roundLimit
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Texd {
            id: remainText
            font.pixelSize: thb
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "求解"
            onClicked: {
                repAnswer.model = pEffGb.answer();
                rectAnswer.visible = true;
            }
        }
    }

    Column {
        id: resultRect
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
                        "和了率",
                        "平均和了巡目",
                        "平均和了分数"
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
        tw: room.height / 20
        twb: room.height / 13
        x: (room.width - 13 * twb) / 2;
        y: room.height - room.thb - (room.thb / 5);
        width: (room.width + 13 * twb) / 2;
        height: room.thb

        onActionTriggered: {
            rectAnswer.visible = false;
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
