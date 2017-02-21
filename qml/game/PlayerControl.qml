import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Item {
    id: frame

    signal actionTriggered(string actStr, var actArg)

    property bool animEnabled: true
    property string tileSet: "std"
    property real tw
    property real twb
    property color backColor
    property bool face: true // false when no-ten at ryuukyoku
    property var can: { "tsumokiri": false, "pass": false }
    property point outCoord
    property bool green: false
    property alias drawnStr: drawn.tileStr
    property string _lastDiscardStr: ""

    ActionButtonBar {
        id: actionButtons
        buttonHeight: twb / 4 * 3 + 3
        anchors.bottom: hand.top
        anchors.right: drawn.visible ? drawn.right : hand.right
        anchors.bottomMargin: global.size.space
        anchors.rightMargin: 1
        onActionTriggered: { frame.actionTriggered(actStr, 777); }
    }

    Tile {
        property alias inAnim: inAnim
        id: drawn
        anchors.left: hand.right
        anchors.leftMargin: global.size.space
        z: 5
        tileSet: frame.tileSet
        tileWidth: twb
        backColor: frame.backColor
        onClicked: {
            _handleDrawnClicked();
        }
        NumberAnimation {
            id: inAnim
            target: drawn
            property: "y"
            from: -twb
            to: 0
            duration: 200
            easing.type: Easing.OutQuad
        }
        SequentialAnimation {
            id: outAnim
            NumberAnimation {
                target: drawn
                property: "y"
                duration: 100
                from: 0
                to: -twb
                easing.type: Easing.Linear
            }
            ScriptAction {
                script: {
                    drawn.tileStr = "hide";
                }
            }
        }
        SequentialAnimation {
            id: greenSpinAnim
            NumberAnimation {
                target: drawn
                property: "y"
                duration: 150
                from: 0
                to: -twb * 0.5
                easing.type: Easing.OutQuad
            }
            PauseAnimation {
                duration: 400
            }
            NumberAnimation {
                target: drawn
                property: "y"
                duration: 150
                from: -twb * 0.5
                to: 0
                easing.type: Easing.Linear
            }
        }

        function activate() {
            drawn.dark = false;
            drawn.clickable = true;
        }

        function deactivate() {
            drawn.dark = false
            drawn.clickable = false;
        }
    }

    ListView {
        id: hand
        width: twb * handModel.count
        height: 1.35 * twb
        z: 5
        model: ListModel { id: handModel }
        orientation: Qt.Horizontal
        delegate: Tile {
            id: handDele
            tileSet: frame.tileSet
            tileWidth: twb
            backColor: frame.backColor
            onClicked: {
                if (green)
                    greenSwapAnim.start();
                else
                    swapOut(index)
                frame.actionTriggered("SWAP_OUT", tileStr);
            }
            tileStr: frame.face && modelTileStr ? modelTileStr : "back"
            dark: modelDark
            clickable: modelClickable

            FloatButton {
                width: twb - 5
                height: 1.35 * twb / 2
                anchors.bottom: parent.bottom
                actStr: modelFloatAct
                onButtonPressed: {
                    frame.actionTriggered(modelFloatAct, modelFloatArg);
                }
            }

            SequentialAnimation {
                id: greenSwapAnim
                NumberAnimation {
                    target: handDele
                    property: "y"
                    duration: 150
                    from: 0
                    to: -twb * 0.5
                    easing.type: Easing.OutQuad
                }
                PauseAnimation {
                    duration: 400
                }
                NumberAnimation {
                    target: handDele
                    property: "y"
                    duration: 150
                    from: -twb * 0.5
                    to: 0
                    easing.type: Easing.OutQuad
                }
            }
        }

        add: Transition {
            enabled: frame.animEnabled
            NumberAnimation {
                property: "y"
                from: -twb
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        remove: Transition {
            enabled: frame.animEnabled
            NumberAnimation {
                property: "y"
                duration: 100
                to: -twb
                easing.type: Easing.Linear
            }
        }

        displaced: Transition {
            enabled: frame.animEnabled
            NumberAnimation {
                property: "x"
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        populate: Transition {
            id: popTrans
            enabled: frame.animEnabled
            SequentialAnimation {
                PropertyAction { property: "visible"; value: false }

                PauseAnimation {
                    duration: (popTrans.ViewTransition.index -
                               popTrans.ViewTransition.targetIndexes[0]) * 100
                }

                PropertyAction { property: "visible"; value: true }

                NumberAnimation {
                    property: "x"
                    duration: 300
                    from: 13 * twb
                    easing.type: Easing.InOutQuad
                }
            }
        }

        function activate(mask) {
            for (var i = 0; i < handModel.count; i++) {
                var ok = !!(mask & (1 << i));
                handModel.set(i, { modelDark: !ok, modelClickable: ok });
            }
        }

        function deactivate() {
            for (var i = 0; i < handModel.count; i++) {
                handModel.set(i, { modelDark: false, modelClickable: false,
                                   modelFloatAct: "", modelFloatArg: "-1" });
            }
        }
    } // end of hand

    ListView {
        id: barks

        width: parent.width // enough is good
        height: parent.height // enough is good
        anchors.right: frame.right
        anchors.bottom: frame.bottom
        orientation: Qt.Horizontal
        layoutDirection: Qt.RightToLeft
        spacing: 1
        model: ListModel { id: barksModel }
        delegate: Meld {
            tileSet: frame.tileSet
            tw: frame.tw
            backColor: frame.backColor
            meld: modelMeld
            anchors.bottom: parent.bottom
            FloatButton {
                width: 1.35 * frame.tw - 4
                height: frame.tw
                y: -(frame.tw / 2)
                x:  meld.open === 0 ? 2 : (meld.open === 1 ? tw + 2 : tw * 2 + 2);
                actStr: modelFloatAct
                onButtonPressed: {
                    frame.actionTriggered(modelFloatAct, modelFloatArg);
                }
            }
        }
    }

    function clear() {
        handModel.clear();
        barksModel.clear();
        drawn.tileStr = "hide";
    }

    function deal(init) {
        hand.model = []; // to trigger populate transition
        for (var i in init) {
            var model = {
                modelDark: false,
                modelClickable: false,
                modelFloatAct: "",
                modelFloatArg: "-1",
                modelTileStr: init[i],
            };
            handModel.append(model);
        }
        hand.model = handModel;
        drawn.tileStr = "hide";
        frame.face = true;
    }

    function activate(action, lastDiscardStr) {
        drawn.dark = true; // will be unset if needed
        for (var actStr in action) {
            switch (actStr) {
            case "SWAP_OUT":
                hand.activate(action[actStr]);
                break;
            case "SPIN_OUT":
                frame.can.tsumokiri = true;
                drawn.activate();
                break;
            case "CHII_AS_LEFT":
                handModel.set(_offIndexInHand34(lastDiscardStr, 1),
                              { modelFloatAct: actStr, modelFloatArg: "2" });
                break;
            case "CHII_AS_MIDDLE":
                handModel.set(_offIndexInHand34(lastDiscardStr, -1),
                              { modelFloatAct: actStr, modelFloatArg: "2" });
                break;
            case "CHII_AS_RIGHT":
                handModel.set(_offIndexInHand34(lastDiscardStr, -2),
                              { modelFloatAct: actStr, modelFloatArg: "2" });
                break;
            case "PON":
                handModel.set(_indexInHand34(lastDiscardStr) + 1,
                              { modelFloatAct: actStr, modelFloatArg: "2" });
                break;
            case "DAIMINKAN":
                handModel.set(_indexInHand34(lastDiscardStr) + 2,
                              { modelFloatAct: actStr, modelFloatArg: "2" });
                break;
            case "ANKAN":
                for (var i = 0; i < action[actStr].length; i++) {
                    handModel.set(_indexInHand34(action[actStr][i]) + 2,
                                  { modelFloatAct: actStr, modelFloatArg: action[actStr][i] });
                }
                break;
            case "KAKAN":
                for (var j = 0; j < action[actStr].length; j++) {
                    var model = {
                        modelFloatAct: actStr,
                        // why string -> see deactivate()
                        modelFloatArg: "" + action[actStr][j]
                    };
                    barksModel.set(action[actStr][j], model);
                }
                break;
            case "PASS":
                frame.can.pass = true;
                // fall through
            case "TSUMO":
            case "RON":
            case "RIICHI":
            case "RYUUKYOKU":
            case "IRS_CLICK":
                actionButtons.add(actStr);
                break;
            default:
                throw "PlayerControl: unhandled act: " + actStr;
            }
        }
    }

    function deactivate() {
        frame.can.tsumokiri = false;
        frame.can.pass = false;
        hand.deactivate();
        drawn.deactivate();
        actionButtons.clear();
        // using string as modelFloatArg since list model is kind of
        // internally statically typed and say don't allow blablabla
        for (var i = 0; i < barksModel.count; i++)
            barksModel.set(i, { modelFloatAct: "", modelFloatArg: "-1" });
    }

    function draw(t) {
        drawn.tileStr = t;
        // dark and clickable are initially set false
        drawn.dark = false;
        drawn.clickable = false;

        if (frame.animEnabled)
            drawn.inAnim.start();
    }

    function _handleDrawnClicked() {
        if (green)
            greenSpinAnim.start();
        else
            _spinOut();
        frame.actionTriggered("SPIN_OUT", -1);
    }

    // called only by self and set-background-demo
    function swapOut(outPos) {
        _lastDiscardStr = handModel.get(outPos).modelTileStr;
        outCoord = mapFromItem(frame, outPos * twb, 0);
        handModel.remove(outPos, 1);
        if (drawn.visible)
            insertDrawn();
    }

    function _spinOut() {
        _lastDiscardStr = drawn.tileStr;
        outCoord = mapFromItem(drawn, 0, 0);
        outAnim.start();
    }

    function _offIndexInHand34(tileStr, off) {
        var arr = [
            "1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m",
            "1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p",
            "1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s"
        ];
        var ts = tileStr[0] === "0" ? ("5" + tileStr[1]) : tileStr;
        var id34 = arr.indexOf(ts);
        return _indexInHand34(arr[id34 + off]);
    }

    function _indexInHand37(tileStr) {
        for (var i = 0; i < handModel.count; i++)
            if (handModel.get(i).modelTileStr === tileStr)
                return i;
        return -1;
    }

    function _indexInHand34(tileStr) {
        if (tileStr[0] === "0" || tileStr[0] === "5") {
            var resRed = _indexInHand37("0" + tileStr[1])
            return resRed >= 0 ? resRed : _indexInHand37("5" + tileStr[1]);
        }

        return _indexInHand37(tileStr);
    }

    function bark(bark, spin) {
        var ti;
        if (bark.isAnkan) {
            if (spin) {
                handModel.remove(_indexInHand34(bark[0].substr(0, 2)), 3);
                drawn.tileStr = "hide";
            } else {
                handModel.remove(_indexInHand34(bark[0].substr(0, 2)), 4);
                insertDrawn();
            }
        } else if (bark.isKakan) {
            for (var i = 0; i < barksModel.count; i++) {
                if (barksModel.get(i).modelMeld[0].substr(0, 2) === bark[0].substr(0, 2)) {
                    barksModel.set(i, { modelMeld: bark });
                    break;
                }
            }

            if (spin) {
                drawn.tileStr = "hide";
            } else {
                handModel.remove(_indexInHand34(bark[3].substr(0, 2)), 1);
                insertDrawn();
            }
        } else { // chii, pon, daiminkan
            var size = bark.isDaiminkan ? 4 : 3;
            for (ti = 0; ti < size; ti++) {
                if (ti === bark.open)
                    continue;
                handModel.remove(_indexInHand37(bark[ti].substr(0, 2)), 1);
            }
        }

        if (!bark.isKakan) {
            var barkModel = {
                modelMeld: bark,
                modelFloatAct: "",
                modelFloatArg: "-1",
                modelIndex: -1
            };
            barksModel.append(barkModel);
        }
    }

    function setBarks(barks) {
        barksModel.clear();
        for (var i = 0; i < barks.length; i++) {
            var barkModel = {
                modelMeld: barks[i],
                modelFloatAct: "",
                modelFloatArg: "-1",
                modelIndex: -1
            };
            barksModel.append(barkModel);
        }
    }

    function order37(tileStr) {
        var arr = [
            "1m", "2m", "3m", "4m", "0m", "5m", "6m", "7m", "8m", "9m",
            "1p", "2p", "3p", "4p", "0p", "5p", "6p", "7p", "8p", "9p",
            "1s", "2s", "3s", "4s", "0s", "5s", "6s", "7s", "8s", "9s",
            "1f", "2f", "3f", "4f", "1y", "2y", "3y"
        ];
        return arr.indexOf(tileStr);
    }

    function insertDrawn() {
        var inPos = 0;
        var ndl = order37(drawn.tileStr)
        while (inPos < handModel.count && ndl > order37(handModel.get(inPos).modelTileStr))
            inPos++;

        var drawnModel = {
            modelTileStr: drawn.tileStr,
            modelDark: drawn.dark,
            modelClickable: drawn.clickable,
            modelFloatAct: "",
            modelFloatArg: "-1"
        };

        handModel.insert(inPos, drawnModel);
        drawn.tileStr = "hide";
    }

    function easyPass() {
        if (frame.can.tsumokiri) {
            _handleDrawnClicked();
        } else if (frame.can.pass) {
            frame.actionTriggered("PASS", -765);
        }
        // else do nothing
    }

    function fixSyncError(tileStr) {
        function searchAndSwapOut() {
            for (var outPos = 0; outPos < handModel.count; outPos++) {
                if (handModel.get(outPos).modelTileStr === tileStr) {
                    swapOut(outPos);
                    break;
                }
            }
        }

        if (drawn.visible) {
            // if drawn.visible, user didn't do anything, or spin-out anim playing
            // (all actions set drawn invisible)
            // case 1: auto-move after riichi
            // case 2: server sweep-one and local timeout
            // case 3: spin-out anim playing
            _spinOut();
        } else if (handModel.count % 3 === 2) {
            // case: server sweep-one, local timeout after bark
            searchAndSwapOut();
        } else if (_lastDiscardStr !== tileStr) {
            // case: server sweep-one intersects local discard
            // simply fix by picking-back and re-discard
            drawn.tileStr = _lastDiscardStr;
            searchAndSwapOut();
        }
    }
} // end of Item

