import QtQuick 2.0
import rolevax.sakilogy 1.0
import "widget"

Item {
    id: table
    width: height / 9 * 10
    // height is set by outside item

    signal closed

    property bool animEnabled: true
    property bool keepOpen: false
    property string tileSet: "std"

    // small tile width, height, and thickness
    property int tw: table.height / 20
    property int th: 1.35 * tw

    // big tile width and height
    property int twb: table.height / (global.mobile ? 13 : 17)
    property int thb: 1.35 * twb

    property var backColors: PGlobal.backColors
    property int colorIndex: 1 // will be updated to 0

    // set by parent
    property var photos
    property Rectangle green

    property alias pTable: pTable
    property alias middle: middle // for temp-dealer showing

    property string _lastDiscardStr

    PTable {
        id: pTable
        onFirstDealerChoosen: {
            function cb() {
                middle.setDealer(dealer)
                pointBoard.initDealer = dealer;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onRoundStarted: {
            function cb() {
                middle.setRound(round, extra);
                middle.setDealer(dealer);
                middle.wallRemain = 122;
                for (var i = 0; i < 4; i++) {
                    if (i === dealer)
                        photos[i].setBars(extra, deposit);
                    else
                        photos[i].removeBars();
                }

                colorIndex = (colorIndex + 1) % backColors.length;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onCleaned: {
            function cb() {
                playerControl.clear();
                logBox.clear();
                doraIndic.doraIndic = [];
                var i;
                for (i = 0; i < 3; i++)
                    oppoControls.itemAt(i).clear();
                for (i = 0; i < 4; i++)
                    rivers.itemAt(i).clear();
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onDiced: {
            function cb() {
                middle.setDice(die1, die2);
            }

            animBuf.push({ callback: cb, duration: 1600 });
        }

        onDealt: {
            function cb() {
                playerControl.deal(init);
                oppoControls.itemAt(0).deal();
                oppoControls.itemAt(1).deal();
                oppoControls.itemAt(2).deal();
            }

            function wr() {
                middle.wallRemain = 70;
            }

            animBuf.push({ callback: cb, duration: 1600 });
            animBuf.push({ callback: wr, duration: 0 });
        }

        onFlipped: {
            function cb() {
                doraIndic.doraIndic.push(newIndic);
                doraIndic.doraIndicChanged();
                resultWindow.doraIndic.doraIndic = doraIndic.doraIndic;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onActivated: {
            function cb() {
                if (action.END_TABLE || action.NEXT_ROUND) {
                    resultWindow.activate(action);
                } else if (action.DICE) {
                    middle.activateDice();
                } else if (action.IRS_CHECK) {
                    irsCheckBox.activate(action);
                } else if (action.IRS_RIVAL) {
                    for (var i = 0; i < action.IRS_RIVAL.length; i++)
                        photos[action.IRS_RIVAL[i]].activateIrsRival();
                } else {
                    if (action.CHII || action.PON || action.DAIMINKAN
                            || action.RON)
                        rivers.itemAt(lastDiscarder).showCircle(true);
                    playerControl.activate(action, _lastDiscardStr);
                }
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onDrawn: {
            function cb() {
                middle.wallRemain--;
                if (who === 0)
                    playerControl.draw(tile);
                else
                    oppoControls.itemAt(who - 1).draw();
            }

            var delay = rinshan ? 500 : 0;
            animBuf.push({ callback: cb, duration: 100, prelude: delay });
        }

        onDiscarded: {
            function cb() {
                var osc; // out-tile's scene coord

                if (who === 0) {
                    osc = spin ? playerControl.spinOut() : playerControl.swapOut();
                    osc = mapFromItem(playerControl, osc.x, osc.y);
                    osc = mapToItem(rivers.itemAt(0), osc.x, osc.y);
                } else {
                    var oppo = oppoControls.itemAt(who - 1);
                    osc = spin ? oppo.spinOut() : oppo.swapOut();
                    osc = mapFromItem(playerControl, osc.x, osc.y);
                    osc = mapToItem(rivers.itemAt(0), osc.x, osc.y);
                }

                rivers.itemAt(who).add(tile, osc);
                _lastDiscardStr = tile.modelTileStr;
            }

            animBuf.push({ callback: cb, duration: 200 });
        }

        onRiichied: {
            function cb() {
                shockers.itemAt(who).shock("RIICHI");
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onRiichiPassed: {
            function cb() {
                middle.addBar(who);
            }

            animBuf.push({ callback: cb, duration: 100 });
        }

        onBarked: {
            function cb() {
                shockers.itemAt(who).shock(actStr);
                if (who === 0)
                    playerControl.bark(bark, spin);
                else
                    oppoControls.itemAt(who - 1).bark(bark, spin);
                if (fromWhom >= 0)
                    rivers.itemAt(fromWhom).sub();
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onRoundEnded: {
            function cb() {
                var i;
                for (i = 1; i < 4; i++)
                    oppoControls.itemAt(i - 1).setHand(hands[i]);

                logBox.clear();
                middle.removeBars();

                if (result === "TSUMO") {
                    shockers.itemAt(openers[0]).shock(result);
                    if (openers[0] !== 0)
                        oppoControls.itemAt(openers[0] - 1).pushDown(true, forms[0].pick);

                    resultWindow.uraIndic.doraIndic = uraIndics;
                    resultWindow.agari(openers, -1, forms);
                } else if (result === "RON") {
                    for (i = 0; i < openers.length; i++) {
                        var who = openers[i];
                        shockers.itemAt(who).shock(result);
                        if (who !== 0)
                            oppoControls.itemAt(who - 1).pushDown(true);
                    }

                    rivers.itemAt(gunner).showCircle(false);
                    resultWindow.uraIndic.doraIndic = uraIndics;

                    // array 'openers' may be longer than actual winners
                    // since it contains jumpees
                    resultWindow.agari(openers, gunner, forms);
                } else {
                    var whoReady = [ false, false, false, false ];
                    for (var j = 0; j < openers.length; j++) {
                        if (result === "SCHR")
                            shockers.itemAt(openers[j]).shock("RON");
                        whoReady[openers[j]] = true;
                    }

                    playerControl.face = whoReady[0] || result === "SCRC";
                    for (var i = 0; i < 3; i++) {
                        var face = whoReady[i + 1] || result == "SCRC";
                        oppoControls.itemAt(i).pushDown(face);
                    }

                    resultWindow.ryuukyoku(result);
                }
            }

            // extra duration to delay point change animation
            animBuf.push({ callback: cb, duration: 200 });
        }

        onPointsChanged: {
            function cb() {
                middle.setPoints(points);
                pointBoard.points = points;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onTableEnded: {
            function cb() {
                resultFinal.names = [ resultWindow.names[rank[0]],
                                      resultWindow.names[rank[1]],
                                      resultWindow.names[rank[2]],
                                      resultWindow.names[rank[3]] ];
                resultFinal.points = [ scores[rank[0]],
                                       scores[rank[1]],
                                       scores[rank[2]],
                                       scores[rank[3]] ];
                resultFinal.visible = true;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onPoppedUp: {
            function cb() {
                if (who !== 0) // omit Ai's log
                    return;

                if (str === "GREEN") {
                    green.visible = !green.visible;
                } else {
                    logBox.log(str);
                }
            }

            animBuf.push({ callback: cb, duration: 0 });
        }

        onJustPause: {
            animBuf.push({ callback: function() { }, duration: ms });
        }

        onJustSetOutPos: {
            function cb() {
                playerControl.outPos = outPos;
            }

            animBuf.push({ callback: cb, duration: 0 });
        }
    }

    AnimadionBuffer { id: animBuf }

    Middle {
        id: middle
        animEnabled: table.animEnabled
        width: 6 * tw
        height: width
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2 - 20
        z: 4
        onDiceRolled: {
            logBox.clear();

            // '234' is useless
            pTable.action("DICE", 234);
        }
    }

    IrsCheckBox {
        id: irsCheckBox
        z: 5
        anchors.centerIn: parent
        fontSize: global.size.middleFont
        onActionTriggered: {
            pTable.action("IRS_CHECK", mask);
        }
    }

    Rectangle {
        id: resultRect

        anchors.centerIn: parent
        width: resultWindow.width + pointBoard.width + 20
        height: resultWindow.height + 4
        color: "#AA000000"
        visible: resultWindow.visible
        opacity: resultWindow.opacity
        z: 15
    }

    Row {
        anchors.centerIn: parent
        z: 16

        ResultWindow {
            id: resultWindow
            tileSet: table.tileSet
            backColor: table.backColors[table.colorIndex]
            tw: table.tw
            onNextRound: pTable.action("NEXT_ROUND", -1);
            onEndTable: pTable.action("END_TABLE", -1);
            onVisibleChanged: {
                if (table.animEnabled && visible)
                    animResult.start();
            }

            SequentialAnimation {
                id: animResult

                PropertyAction {
                    target: resultWindow
                    property: "opacity"
                    value: 0
                }

                PauseAnimation { duration: 700 }

                PropertyAnimation {
                    target: resultWindow
                    property: "opacity"
                    from: 0;
                    to: 1;
                    duration: 200
                }
            }
        }

        PointBoard {
            id: pointBoard
            tw: table.tw
            visible: resultWindow.visible
            opacity: resultWindow.opacity
        }
    }

    ResultFinal {
        id: resultFinal
        visible: false
        height: 0.55 * table.height
        onClosed: {
            pTable.saveRecord();
            table.closed();
        }
    }

    LogBox {
        id: logBox
        width: table.width / 3 * 2
        fontSize: global.mobile ? tw : tw / 3 * 2
        z: 16
        anchors.centerIn: parent
    }

    Repeater {
        id: rivers
        model: 4
        River {
            tileSet: table.tileSet
            animEnabled: table.animEnabled
            tw: table.tw
            x: middle.x + (index % 3 !== 0) * middle.width
            y: middle.y + (index < 2) * middle.height
            transform: Rotation {angle: -90 * index}
        }
    }

    DoraIndic {
        id: doraIndic
        tileSet: table.tileSet
        backColor: table.backColors[table.colorIndex]
        tw: table.tw
        x: 1.7 * table.th;
        y: 2 * tw + table.th
    }

    Repeater {
        id: shockers
        model: 4
        Shocker {
            x: [0, table.width - height, table.width, height][index]
            y: [table.height - height - 40, table.height, height, 0][index]
            z: 5
            width: [table.width, table.height, table.width, table.height][index]
            height: 0.22 * table.height
            transform: Rotation { angle: [0, -90, 180, 90][index] }
        }
    }

    Repeater {
        id: oppoControls
        model: 3
        z: 3
        OppoControl {
            z: 2
            animEnabled: table.animEnabled
            keepOpen: table.keepOpen
            tileSet: table.tileSet
            backColor: table.backColors[table.colorIndex]
            tw: table.tw
            width: ((index === 1 ? table.width : table.height) + 13 * tw) / 2
            height: table.th + 3
            transform: [
                Rotation { angle: -90 * (index + 1) },
                Translate {
                    x: [ table.width - height, width, height ][index]
                    y: [ width, height, table.height - width ][index]
                }
            ]
        }
    }

    PlayerControl {
        id: playerControl
        animEnabled: table.animEnabled
        tileSet: table.tileSet
        backColor: table.backColors[table.colorIndex]
        tw: table.tw
        twb: table.twb
        x: (table.width - 13 * twb) / 2;
        y: table.height - table.thb - (table.thb / 5);
        z: 3
        width: (table.width + 13 * twb) / 2;
        height: table.thb

        onActionTriggered: {
            // deactivate
            playerControl.deactivate();
            for (var i = 0; i < 4; i++)
                rivers.itemAt(i).clearCircles();
            logBox.clear();

            pTable.action(actStr, actArg);
        }
    }

    focus: true
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape
                || event.key === Qt.Key_Back) {
            table.closed();
            event.accepted = true;
        } else if (event.key === Qt.Key_S) {
            pTable.saveRecord();
            table.closed();
            event.accepted = true;
        } else if ((event.modifiers & Qt.ControlModifier)
                   && event.key === Qt.Key_K) {
            // press Ctrl+K to enter debug mode
            table.keepOpen = !table.keepOpen;
            event.accepted = true;
        }
    }

    function setNames(names) {
        pointBoard.setNames(names);
        resultWindow.names = names
        for (var i = 0; i < 4; i++)
            photos[i].name = names[i];
    }

    function easyPass() {
        playerControl.easyPass();
    }

    function showSnap(snap) {
        var i;

        resultWindow.visible = false;
        pointBoard.points = snap.points;
        doraIndic.doraIndic = snap.drids;

        middle.setRound(snap.round, snap.extraRound);
        middle.setPoints(snap.points);
        middle.setDice(snap.die1, snap.die2);
        middle.setDealer(snap.dealer);
        middle.wallRemain = 0; // force change signal
        middle.wallRemain = snap.wallRemain;
        middle.removeBars();

        playerControl.clear();
        playerControl.deal(snap.players[0].hand);
        playerControl.setBarks(snap.players[0].barks)

        for (i = 0; i < 3; i++) {
            oppoControls.itemAt(i).clear();
            oppoControls.itemAt(i).setHand(snap.players[i + 1].hand);
            oppoControls.itemAt(i).pushDown(true);
            oppoControls.itemAt(i).setBarks(snap.players[i + 1].barks);
        }

        for (i = 0; i < 4; i++) {
            rivers.itemAt(i).set(snap.players[i].river);
            if (snap.players[i].riichiBar)
                middle.addBar(i);
        }

        if (snap.whoDrawn === 0)
            playerControl.draw(snap.drawn);
        else if (snap.whoDrawn > 0)
            oppoControls.itemAt(snap.whoDrawn - 1).setDrawn(snap.drawn);

        if (snap.endOfRound) {
            if (snap.result === "TSUMO" || snap.result === "RON") {
                resultWindow.doraIndic.doraIndic = snap.drids;
                resultWindow.uraIndic.doraIndic = snap.urids;
                // array 'openers' may be longer than actual winners
                // since it contains jumpees
                resultWindow.agari(snap.openers, snap.gunner, snap.forms);
            } else {
                resultWindow.ryuukyoku(snap.result);
            }
        }
    }
}

