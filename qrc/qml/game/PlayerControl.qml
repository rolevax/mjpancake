import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Item {
    id: frame

    signal actionTriggered(string actStr, int actArg, string actTile)

    property bool animEnabled: true
    property string tileSet: "std"
    property real tw
    property real twb
    property color backColor
    property bool face: true // false when no-ten at ryuukyoku
    property point outCoord
    property bool green: false
    property alias drawnStr: drawn.tileStr

    property bool _handActivated: false
    property int _canSwapOutMask: 0
    property int _canSwapRiichiMask: 0
    property bool _canSpinOut: false
    property bool _canSpinRiichi: false
    property bool _canPass: false
    property string _actBark: ""
    property var _outModel: null
    property int _outPos

    ActionButtonBar {
        id: actionButtons
        buttonHeight: twb / 4 * 3 + 3
        anchors.bottom: hand.top
        anchors.right: drawn.visible ? drawn.right : hand.right
        anchors.bottomMargin: global.size.space
        anchors.rightMargin: 1
        onActionTriggered: { frame.actionTriggered(actStr, -1, ""); }
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
        clickable: actionButtons.riichi ? _canSpinRiichi : _canSpinOut
        dark: _handActivated && !clickable
        onClicked: { _handleDrawnClicked(); }
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
            onClicked: { _handleHandClicked(index, tileStr, greenSwapAnim); }
            tileStr: frame.face && modelTileStr ? modelTileStr : "back"
            dark: _handActivated && !clickable
            clickable: _handActivated && _canSwapOutAt(index)

            FloatButton {
                width: twb - 5
                height: 1.35 * twb / 2
                anchors.bottom: parent.bottom
                actStr: modelFloatAct
                onButtonPressed: {
                    switch (modelFloatAct) {
                    case "CHII_AS_LEFT":
                    case "CHII_AS_MIDDLE":
                    case "CHII_AS_RIGHT":
                    case "PON":
                        _enterBark(modelFloatAct, modelTileStr);
                        break;
                    case "DAIMINKAN":
                        frame.actionTriggered("DAIMINKAN", -1, "");
                        break;
                    case "ANKAN":
                        frame.actionTriggered("ANKAN", -1, modelTileStr);
                        break;
                    default:
                        throw "hand-float-btn: unexpected actStr " + modelFloatAct;
                    }
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
                onButtonPressed: { frame.actionTriggered(modelFloatAct, index, ""); }
            }
        }
    }

    function clear() {
        deactivate();
        handModel.clear();
        barksModel.clear();
        drawn.tileStr = "hide";
    }

    function deal(init) {
        hand.model = []; // to trigger populate transition
        for (var i in init) {
            var model = {
                modelFloatAct: "",
                modelTileStr: init[i],
            };
            handModel.append(model);
        }
        hand.model = handModel;
        drawn.tileStr = "hide";
        frame.face = true;
    }

    function activate(action, lastDiscardStr) {
        for (var actStr in action) {
            switch (actStr) {
            case "SWAP_OUT":
                _canSwapOutMask = action[actStr];
                _handActivated = true;
                break;
            case "SPIN_OUT":
                _canSpinOut = true;
                _handActivated = true;
                break;
            case "SWAP_RIICHI":
                actionButtons.enableRiichi();
                _canSwapRiichiMask = action[actStr];
                _handActivated = true; // assume no 'cannot dama' case
                break;
            case "SPIN_RIICHI":
                actionButtons.enableRiichi();
                _canSpinRiichi = true;
                _handActivated = true; // assume no 'cannot dama' case
                break;
            case "CHII_AS_LEFT":
                handModel.set(_offIndexInHand34(lastDiscardStr, 1), { modelFloatAct: actStr });
                break;
            case "CHII_AS_MIDDLE":
                handModel.set(_offIndexInHand34(lastDiscardStr, -1), { modelFloatAct: actStr });
                break;
            case "CHII_AS_RIGHT":
                handModel.set(_offIndexInHand34(lastDiscardStr, -2), { modelFloatAct: actStr });
                break;
            case "PON":
                handModel.set(_indexInHand34(lastDiscardStr) + 1, { modelFloatAct: actStr });
                break;
            case "DAIMINKAN":
                handModel.set(_indexInHand34(lastDiscardStr) + 2, { modelFloatAct: actStr });
                break;
            case "ANKAN":
                for (var i = 0; i < action[actStr].length; i++) {
                    handModel.set(_indexInHand34(action[actStr][i]) + 2, { modelFloatAct: actStr });
                }
                break;
            case "KAKAN":
                for (var j = 0; j < action[actStr].length; j++) {
                    barksModel.set(action[actStr][j], { modelFloatAct: "KAKAN" });
                }
                break;
            case "PASS":
                _canPass = true;
                // fall through
            case "TSUMO":
            case "RON":
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
        _handActivated = false;
        _canPass = false;
        _canSpinOut = false;
        _canSpinRiichi = false;
        _canSwapOutMask = 0;
        _canSwapRiichiMask = 0;
        actionButtons.clear();

        for (var i = 0; i < handModel.count; i++)
            handModel.set(i, { modelFloatAct: "" });
        for (var i = 0; i < barksModel.count; i++)
            barksModel.set(i, { modelFloatAct: "" });
    }

    function draw(t) {
        drawn.tileStr = t;
        if (frame.animEnabled)
            drawn.inAnim.start();
    }

    function _canSwapOutAt(index) {
        return !!((actionButtons.riichi ? _canSwapRiichiMask : _canSwapOutMask) & (1 << index));
    }

    function _handleDrawnClicked() {
        if (green)
            greenSpinAnim.start();
        else
            _spinOut();
        frame.actionTriggered(actionButtons.riichi ? "SPIN_RIICHI" : "SPIN_OUT", -1, "");
    }

    function _handleHandClicked(index, tileStr, greenSwapAnim) {
        if (green)
            greenSwapAnim.start();
        else
            swapOut(index)

        var actStr = _actBark;
        var actArg = !!_actBark ? 2 : -1;
        _actBark = "";
        if (!actStr)
            actStr = actionButtons.riichi ? "SWAP_RIICHI" : "SWAP_OUT";

        frame.actionTriggered(actStr, actArg, tileStr);
    }

    // called only by self and set-background-demo
    function swapOut(outPos) {
        // backup for fixBarkFailureIfAny()
        _outModel = {
            modelTileStr: handModel.get(outPos).modelTileStr ,
            modelFloatAct: ""
        };
        _outPos = outPos;

        outCoord = mapFromItem(frame, outPos * twb, 0);
        handModel.remove(outPos, 1);
        if (drawn.visible)
            insertDrawn();
    }

    function _spinOut() {
        outCoord = mapFromItem(drawn, 0, 0);
        outAnim.start();
    }

    function _t34Plus(tileStr, off) {
        var arr = [
            "1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m",
            "1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p",
            "1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s"
        ];
        var ts = tileStr[0] === "0" ? ("5" + tileStr[1]) : tileStr;
        var id34 = arr.indexOf(ts);
        return arr[id34 + off];
    }

    function _offIndexInHand34(tileStr, off) {
        return _indexInHand34(_t34Plus(tileStr, off));
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

    function _tileInHand34(tileStr) {
        return handModel.get(_indexInHand34(tileStr)).modelTileStr;
    }

    function _barkMask(banOne1, banOne2, banAll1, banAll2) {
        var banOne1Used = false;
        var banOne2Used = false;
        var res = 0;
        var banAll3 = "";

        if (banAll1[0] === "5")
            banAll3 = "0" + banAll1[1];
        else if (banAll1[0] === "0")
            banAll3 = "5" + banAll1[1];
        else if (banAll2[0] === "5")
            banAll3 = "0" + banAll2[1];
        else if (banAll2[0] === "0")
            banAll3 = "5" + banAll2[1];

        for (var i = 0; i < handModel.count; i++) {
            var tile = handModel.get(i).modelTileStr;
            var bit = 1;

            if (!banOne1Used && tile === banOne1) {
                bit = 0;
                banOne1Used = true;
            } else if (!banOne2Used && tile === banOne2) {
                bit = 0;
                banOne2Used = true;
            } else if (tile === banAll1 || tile === banAll2 || tile === banAll3) {
                bit = 0;
            }

            res |= bit << i;
        }

        return res;
    }

    function _enterBark(actStr, clickedTileStr) {
        frame.deactivate();
        _actBark = actStr;
        var banOne1 = "";
        var banOne2 = "";
        var banAll1 = "";
        var banAll2 = "";

        switch (actStr) {
        case "CHII_AS_LEFT":
        case "CHII_AS_RIGHT":
            banOne1 = clickedTileStr;
            banOne2 = _tileInHand34(_t34Plus(clickedTileStr, +1)); // assume showAka5 == 2
            banAll1 = _t34Plus(clickedTileStr, -1);
            banAll2 = _t34Plus(clickedTileStr, +2);

            // soslve t34-plush out of range
            if (!banAll1)
                banAll1 = banAll2;
            if (!banAll2)
                banAll2 = banAll1;

            break;
        case "CHII_AS_MIDDLE":
            banOne1 = clickedTileStr;
            banOne2 = _tileInHand34(_t34Plus(clickedTileStr, +2)); // assume showAka5 == 2
            banAll1 = _t34Plus(clickedTileStr, +1);
            break;
        case "PON":
            banAll1 = clickedTileStr;
            break;
        default:
            throw "_enterBark: unexpected actStr " + actStr;
        }

        _canSwapOutMask = _barkMask(banOne1, banOne2, banAll1, banAll2);
        _handActivated = true;
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
            modelFloatAct: "",
        };

        handModel.insert(inPos, drawnModel);
        drawn.tileStr = "hide";
    }

    function easyPass() {
        if (drawn.clickable) {
            _handleDrawnClicked();
        } else if (_canPass) {
            frame.actionTriggered("PASS", -1, "");
        }
        // else do nothing
    }

    function spinIfNotYet() {
        // mainly handle auto-spin after riichi
        if (drawn.visible)
            _spinOut();
    }

    // fix mis-discard when bark failed by other player's
    // ron or bark of higher priority
    function fixBarkFailureIfAny() {
        if (handModel.count % 3 !== 1) {
            handModel.insert(_outPos, _outModel);
        }
    }
} // end of Item

