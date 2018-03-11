import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Item {
    id: table
    width: height / 9 * 10
    // height is set by outside item

    signal closed

    property bool animEnabled: true
    property bool keepOpen: false
    property bool hasTimeout: false
    property string tileSet: "std"

    // small tile width, height, and thickness
    property real tw: 0.05 * table.height
    property real th: 1.35 * tw

    // big tile width and height
    property real _prevTwb
    property real twb: table.height / 17
    property real thb: 1.35 * twb

    property var backColors: PGlobal.backColors
    property int colorIndex: 1 // will be updated to 0

    // set by parent
    property var photos
    property Rectangle green

    property alias pTable: pTable
    property alias middle: middle // for temp-dealer showing

    property string _lastDiscardStr
    property int _nonce

    PTable {
        id: pTable

        onTableEvent: {
            var cb;
            var duration = 0;
            var prelude = 0;

            // assume activation always blocks rendering
            // i.e. activation shall be canceled whenever rendering event arrived
            if (type !== "activated") {
                cb = function() { table.deactivate(); };
                animBuf.push({ callback: cb, duration: 0, prelude: 0 });
            }

            switch (type) {
            case "first-dealer-choosen":
                cb = function() {
                    mount.dealer = args.dealer;
                    middle.setDealer(args.dealer)
                    pointBoard.initDealer = args.dealer;
                };
                break;
            case "round-started":
                cb = function() {
                    middle.setRound(args.round, args.extra);
                    middle.setDealer(args.dealer);
                    middle.wallRemain = 122;
                    mount.visible = true;
                    mount.dealer = args.dealer;
                    for (var i = 0; i < 4; i++) {
                        if (i === args.dealer)
                            photos[i].setBars(args.extra, args.deposit);
                        else
                            photos[i].removeBars();
                    }

                    colorIndex = (colorIndex + 1) % backColors.length;
                };
                break;
            case "cleaned":
                cb = _handleTableEventCleaned;
                break;
            case "diced":
                cb = function() {
                    middle.setDice(args.die1, args.die2);
                    mount.dice = args.die1 + args.die2;
                };
                duration = 1600;
                break;
            case "dealt":
                var preCb = function() {
                    playerControl.deal(args.init);
                    oppoControls.itemAt(0).deal();
                    oppoControls.itemAt(1).deal();
                    oppoControls.itemAt(2).deal();
                    mount.deal();
                };
                animBuf.push({ callback: preCb, duration: 1600 });
                cb =  function() { middle.wallRemain = 70; };
                break;
            case "flipped":
                cb = function() {
                    mount.flip(args.newIndic);
                    resultWindow.doraIndic.doraIndic = mount.doraIndics;
                };
                break;
            case "drawn":
                cb = function() {
                    middle.wallRemain--;
                    if (args.rinshan)
                        mount.backRemain--;
                    else
                        mount.frontRemain--;
                    if (args.who === 0)
                        playerControl.draw(args.tile);
                    else
                        oppoControls.itemAt(args.who - 1).draw();
                };
                duration = 100;
                prelude = args.rinshan ? 300 : 0;
                break;
            case "discarded":
                cb = function() {
                    var osc; // out-tile's scene coord
                    if (args.who === 0) {
                        playerControl.spinIfNotYet();
                        osc = playerControl.outCoord;
                        osc = mapFromItem(playerControl, osc.x, osc.y);
                        osc = mapToItem(rivers.itemAt(0), osc.x, osc.y);
                    } else {
                        var oppo = oppoControls.itemAt(args.who - 1);
                        osc = args.spin ? oppo.spinOut() : oppo.swapOut();
                        osc = mapFromItem(playerControl, osc.x, osc.y);
                        osc = mapToItem(rivers.itemAt(0), osc.x, osc.y);
                    }

                    rivers.itemAt(args.who).add(args.tile, osc);
                    _lastDiscardStr = args.tile.substr(0, 2);
                };
                duration = 800;
                break;
            case "riichi-called":
                cb = function() { shockers.itemAt(args.who).shock("RIICHI"); };
                break;
            case "riichi-established":
                cb = function() { middle.addBar(args.who); };
                duration = 100;
                break;
            case "barked":
                cb = function() {
                    shockers.itemAt(args.who).shock(args.actStr);
                    if (args.who === 0) {
                        playerControl.bark(args.bark, args.spin);
                    } else {
                        oppoControls.itemAt(args.who - 1).bark(args.bark, args.spin);
                        playerControl.fixBarkFailureIfAny();
                    }
                    if (args.fromWhom >= 0)
                        rivers.itemAt(args.fromWhom).sub();
                };
                break;
            case "round-ended":
                cb = function() {
                    endRound(args.result, args.openers, args.gunner,
                             args.hands, args.forms, args.urids);
                    playerControl.fixBarkFailureIfAny();
                };
                // extra duration to delay point change animation
                duration = 200;
                break;
            case "points-changed":
                cb = function() {
                    middle.setPoints(args.points);
                    pointBoard.points = args.points;
                };
                break;
            case "table-ended":
                cb = function() {
                    resultFinal.girlIds = [ resultWindow.girlIds[args.rank[0]],
                                            resultWindow.girlIds[args.rank[1]],
                                            resultWindow.girlIds[args.rank[2]],
                                            resultWindow.girlIds[args.rank[3]] ];
                    resultFinal.points = [ args.scores[args.rank[0]],
                                           args.scores[args.rank[1]],
                                           args.scores[args.rank[2]],
                                           args.scores[args.rank[3]] ];
                    resultFinal.visible = true;
                };
                break;
            case "popped-up":
                cb = function() { logBox.log(args.str); };
                break;
            case "activated":
                cb = function() {
                    activate(args.action, args.lastDiscarder, args.nonce);
                };
                break;
            case "just-pause":
                cb = function() { };
                duration = args.ms;
                break;
            case "just-set-out-pos":
                cb = function() { playerControl.swapOut(args.outPos); };
                break;
            case "resume":
                cb = function() { resume(args); };
                duration = 1600;
                break;
            default:
                throw "PTable::onTableEvent: unkown event type " + type;
            }

            animBuf.push({ callback: cb, duration: duration, prelude: prelude });
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
            table.action("DICE", -1)
        }
    }

    IrsCheckBox {
        id: irsCheckBox
        z: 5
        anchors.centerIn: parent
        fontSize: global.size.middleFont
        onActionTriggered: {
            table.action("IRS_CHECK", mask)
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
            onNextRound: {
                table.action("NEXT_ROUND", -1)
            }
            onEndTable: {
                table.action("END_TABLE", -1)
            }
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
        height: (global.mobile ? 0.65 : 0.55) * table.height
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

    Mount {
        id: mount
        visible: false
        z: middle.pointed ? playerControl.z + 1 : rivers.z
        tw: table.tw
        tileSet: table.tileSet
        backColor: table.backColors[table.colorIndex]
        anchors.centerIn: parent
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
            visible: photos[index + 1].visible
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
        green: table.green.visible
        tw: table.tw
        twb: table.twb
        x: (table.width - 13 * twb) / 2;
        y: table.height - table.thb - 0.02 * table.height;
        z: 3
        width: (table.width + 13 * twb) / 2;
        height: table.thb
        onActionTriggered: {
            if (photos[0].girlId === 712611 && actStr === "IRS_CLICK")
                table.green.visible = !table.green.visible;
            table.action(actStr, actArg, actTile);
        }
    }

    TimeBar {
        id: timeBar
        width: table.width
        anchors.top: playerControl.bottom
        onFired: {
            table.action("SWEEP", -1, "");
        }
    }

    focus: true
    Keys.onPressed: {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
            if (!pTable.online)
                table.closed();
            event.accepted = true;
        }
    }

    Shortcut {
        sequence: "s"
        onActivated: {
            if (!pTable.online) {
                pTable.saveRecord();
                table.closed();
            }
        }
    }

    onClosed: {
        reset();
    }

    function deactivate() {
        resultWindow.visible = false;
        irsCheckBox.visible = false;
        middle.deactivate();
        playerControl.deactivate();
        for (var i = 0; i < 4; i++) {
            rivers.itemAt(i).clearCircles();
        }
    }

    function action(actStr, actArg, actTile) {
        logBox.clear();

        if (!actTile)
            actTile = "";

        timeBar.cancel();
        table.deactivate();

        pTable.action(actStr, actArg, actTile, _nonce);
    }

    function setGirlIds(girlIds) {
        pointBoard.setGirlIds(girlIds);
        resultWindow.girlIds = girlIds
        for (var w = 0; w < 4; w++) {
            photos[w].girlId = girlIds[w];
            rivers.itemAt(w).upDown = (girlIds[w] === 712411 || girlIds[w] === 712412);
        }
    }

    function setUsers(users) {
        for (var i = 0; i < 4; i++)
            photos[i].user = users[i];
    }

    function easyPass() {
        playerControl.easyPass();
    }

    function activate(action, lastDiscarder, nonce) {
        table._nonce = nonce;

        if (table.hasTimeout) {
            if (action.PASS) {
                timeBar.hiddenDuration = 0;
                timeBar.shownDuration = 3000;
            } else {
                timeBar.hiddenDuration = 5000;
                timeBar.shownDuration = 5000;
            }

            timeBar.timeDown();
        }

        PGlobal.forceImmersive();

        if (action.END_TABLE || action.NEXT_ROUND) {
            resultWindow.activate(action);
        } else if (action.DICE) {
            middle.activateDice();
        } else if (action.IRS_CHECK) {
            irsCheckBox.activate(action);
        } else {
            if (action.CHII_AS_LEFT || action.CHII_AS_MIDDLE || action.CHII_AS_RIGHT
                    || action.PON || action.DAIMINKAN || action.RON) {
                rivers.itemAt(lastDiscarder).showCircle(true);
            }
            playerControl.activate(action, _lastDiscardStr);
        }
    }

    function endRound(result, openers, gunner, hands, forms, urids) {
        var i;
        for (i = 0; i < openers.length; i++) {
            if (openers[i] === 0)
                continue;
            oppoControls.itemAt(openers[i] - 1).setHand(hands[i].closed);
        }

        logBox.clear();
        middle.removeBars();

        if (result === "TSUMO") {
            shockers.itemAt(openers[0]).shock(result);
            if (openers[0] !== 0)
                oppoControls.itemAt(openers[0] - 1).pushDown(true, hands[0].pick);

            resultWindow.uraIndic.doraIndic = urids;
            resultWindow.agari(openers, -1, hands, forms);
        } else if (result === "RON") {
            for (i = 0; i < openers.length; i++) {
                var who = openers[i];
                shockers.itemAt(who).shock(result);
                if (who !== 0)
                    oppoControls.itemAt(who - 1).pushDown(true);
            }

            rivers.itemAt(gunner).showCircle(false);
            resultWindow.uraIndic.doraIndic = urids;

            // array 'openers' may be longer than actual winners
            // since it contains jumpees
            resultWindow.agari(openers, gunner, hands, forms);
        } else {
            var whoReady = [ false, false, false, false ];
            for (var j = 0; j < openers.length; j++) {
                if (result === "SCHR")
                    shockers.itemAt(openers[j]).shock("RON");
                whoReady[openers[j]] = true;
            }

            playerControl.face = whoReady[0] || result === "SCRC";
            for (i = 0; i < 3; i++) {
                var face = whoReady[i + 1] || result === "SCRC";
                if (result === "KSKP")
                    oppoControls.itemAt(i).pushDown(face, hands[0].pick);
                else
                    oppoControls.itemAt(i).pushDown(face);
            }

            resultWindow.ryuukyoku(result);
        }
    }

    function resume(snap) {
        var i;

        setGirlIds(snap.girlIds);
        setUsers(snap.users);

        pointBoard.points = snap.points;
        if (snap.dice > 0)
            mount.doraIndics = snap.drids;

        middle.setRound(snap.round, snap.extraRound);
        middle.setPoints(snap.points);
        if (snap.dice > 0) {
            var die1 = Math.floor(snap.dice / 2);
            var die2 = snap.dice - die1;
            middle.setDice(die1, die2);
            mount.dice = snap.dice;
            mount.visible = true;
        }

        middle.setDealer(snap.dealer);
        middle.wallRemain = 0; // force change signal
        middle.wallRemain = snap.wallRemain;
        middle.removeBars();

        mount.dealer = snap.dealer;
        mount.frontRemain = snap.wallRemain + (4 - snap.deadRemain);
        mount.backRemain = snap.deadRemain;

        playerControl.clear();
        if (snap.dice > 0) {
            playerControl.deal(snap.myHand);
            playerControl.setBarks(snap.barkss[0])
            for (i = 0; i < 3; i++) {
                oppoControls.itemAt(i).clear();
                oppoControls.itemAt(i).setStand(13 - 3 * snap.barkss[i + 1].length);
                oppoControls.itemAt(i).setBarks(snap.barkss[i + 1]);
            }

            for (i = 0; i < 4; i++) {
                rivers.itemAt(i).set(snap.rivers[i]);
                if (snap.riichiBars[i])
                    middle.addBar(i);
            }

            if (snap.whoDrawn === 0)
                playerControl.draw(snap.drawn);
            else if (snap.whoDrawn > 0)
                oppoControls.itemAt(snap.whoDrawn - 1).setStandDrawn();
        }
    }

    function showSnap(snap, pers) {
        var i;

        _rotateSnap(snap, pers);

        resultWindow.visible = false;
        pointBoard.points = snap.points;

        middle.setRound(snap.round, snap.extraRound);
        middle.setPoints(snap.points);
        middle.setDice(snap.die1, snap.die2);
        middle.setDealer(snap.dealer);
        middle.wallRemain = 0; // force change signal
        middle.wallRemain = snap.wallRemain;
        middle.removeBars();

        mount.dice = snap.die1 + snap.die2;
        mount.dealer = snap.dealer;
        mount.frontRemain = snap.wallRemain + (4 - snap.deadRemain);
        mount.backRemain = snap.deadRemain;
        mount.doraIndics = snap.drids;
        mount.visible = true;

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
                var hands = [];
                var hand;
                for (i = 0; i < snap.openers.length; i++) {
                    hand = {
                        closed: snap.players[snap.openers[i]].hand,
                        barks: snap.players[snap.openers[i]].barks,
                        pick: snap.result === "TSUMO" ? snap.drawn : snap.cannon
                    };
                    hand.pick.modelLay = true;
                    hands.push(hand);
                }

                resultWindow.doraIndic.doraIndic = snap.drids;
                resultWindow.uraIndic.doraIndic = snap.urids;
                // array 'openers' may be longer than actual winners
                // since it contains jumpees
                resultWindow.agari(snap.openers, snap.gunner, hands, snap.forms);
            } else {
                resultWindow.ryuukyoku(snap.result);
            }
        }
    }

    function _rotateSnap(snap, pers) {
        var i, temp;

        for (i = 0; i < pers; i++) {
            temp = snap.points.shift();
            snap.points.push(temp);

            temp = snap.players.shift();
            snap.players.push(temp);
        }

        snap.dealer = (snap.dealer + 4 - pers) % 4;
        if (snap.whoDrawn >= 0)
            snap.whoDrawn = (snap.whoDrawn + 4 - pers) % 4;
        if (snap.gunner >= 0)
            snap.gunner = (snap.gunner + 4 - pers) % 4;
        for (i = 0; i < snap.openers.length; i++) {
            var o = snap.openers[i];
            o = (o + 4 - pers) % 4;
            snap.openers[i] = o;
        }
    }

    function _handleTableEventCleaned() {
        playerControl.clear();
        logBox.clear();
        mount.clear();
        var i;
        for (i = 0; i < 3; i++)
            oppoControls.itemAt(i).clear();
        for (i = 0; i < 4; i++)
            rivers.itemAt(i).clear();
    }

    function handlePinchStarted() {
        _prevTwb = twb;
    }

    function reset() {
        deactivate();
        _handleTableEventCleaned();
        animBuf.clear();

        green.visible = false;
        mount.visible = false;
        middle.reset();
        setGirlIds([ -1, -1, -1, -1]);
        setUsers([ null, null, null, null  ]);
        for (var i = 0; i < 4; i++)
            photos[i].removeBars();
    }

    function handlePinchUpdated(scale) {
        var next = scale * _prevTwb;
        if (next < tw || next > table.height * 1.6 / 14)
            return;
        twb = next;
    }
}

