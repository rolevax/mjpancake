import QtQuick 2.0
import rolevax.sakilogy 1.0

Item {
    id: frame

    signal actionTriggered(string actStr, int index)

    property bool animEnabled: true
    property string tileSet: "std"
    property int tw
    property int twb
    property color backColor
    property bool face: true // false when no-ten at ryuukyoku
    property var can: { "tsumokiri": false, "pass": false }

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
        onClicked: { frame.actionTriggered("SPIN_OUT", -1); }
        NumberAnimation {
            id: inAnim
            target: drawn
            property: "y"
            from: -twb
            to: 0
            duration: 200
            easing.type: Easing.OutQuad
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
            tileSet: frame.tileSet
            tileWidth: twb
            backColor: frame.backColor
            onClicked: {
                frame.actionTriggered("SWAP_OUT", index);
            }
            tileStr: frame.face && modelTileStr ? modelTileStr : "back"
            lay: modelLay
            dark: modelDark
            clickable: modelClickable

            FloatButton {
                width: twb - 5
                height: 1.35 * twb / 2
                anchors.bottom: parent.bottom
                actStr: modelFloatAct
                actArg: modelFloatArg
                onButtonPressed: {
                    frame.actionTriggered(actStr, actArg);
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
                handModel.set(i, {modelDark: !mask[i],
                                  modelClickable: mask[i]});
            }
        }

        function deactivate() {
            for (var i = 0; i < handModel.count; i++) {
                handModel.set(i, { modelDark: false, modelClickable: false,
                                   modelFloatAct: "", modelFloatArg: -1 });
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
                width: table.th - 4
                height: table.tw
                y: -(table.tw / 2)
                x:  meld.open === 0 ? 2 : (meld.open === 1 ? tw + 2 : tw * 2 + 2);
                actStr: modelFloatAct
                actArg: modelFloatArg
                onButtonPressed: {
                    frame.actionTriggered(actStr, actArg);
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
            init[i].modelDark = false;
            init[i].modelClickable = false;
            init[i].modelFloatAct = "";
            init[i].modelFloatArg = -1;
            handModel.append(init[i]);
        }
        hand.model = handModel;
        drawn.tileStr = "hide";
        frame.face = true;
    }

    function activate(action) {
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
            case "CHII_AS_MIDDLE":
            case "CHII_AS_RIGHT":
            case "PON":
            case "DAIMINKAN":
                handModel.set(action[actStr],
                              { modelFloatAct: actStr, modelFloatArg: 2 });
                            // '2' is dummy, for 'remain-red-max'
                break;
            case "ANKAN":
                for (var i = 0; i < action[actStr].length; i++)
                    handModel.set(action[actStr][i],
                                  { modelFloatAct: actStr, modelFloatArg: action[actStr][i] });
                break;
            case "KAKAN":
                for (var j = 0; j < action[actStr].length; j++)
                    barksModel.set(action[actStr][j],
                                   { modelFloatAct: actStr, modelFloatArg: action[actStr][j] });
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
        for (var i = 0; i < barksModel.count; i++)
            barksModel.set(i, { modelFloatAct: "", modelFloatArg: -1 });
    }

    function draw(t) {
        drawn.lay = t.modelLay;
        drawn.tileStr = t.modelTileStr;
        // dark and clickable are initially set false
        drawn.dark = false;
        drawn.clickable = false;

        if (frame.animEnabled)
            drawn.inAnim.start();
    }

    function outIn(tile, outPos, inPos) {
        var res;
        if (outPos === 13) {
            res = mapFromItem(drawn, 0, 0);
            drawn.tileStr = "hide";
        } else {
            res = mapFromItem(frame, outPos * twb, 0);
            handModel.remove(outPos, 1);
            if (inPos >= 0)
                insertDrawn(inPos);
        }

        return res;
    }

    function outBark(index, index2, bark) {
        if (bark.type === 1) {
            handModel.remove(index2, 1);
            handModel.remove(index, 1);
        } else if (bark.isAnkan) {
            if (index2 >= 0) {
                handModel.remove(index - 2, 4);
                insertDrawn(index2);
            } else {
                handModel.remove(index - 2, 3);
                drawn.tileStr = "hide";
            }
        } else if (bark.isKakan) {
            for (var i = 0; i < barksModel.count; i++) {
                if (barksModel.get(i).modelMeld[0].modelTileStr ===
                        bark[0].modelTileStr) {
                    barksModel.set(i, { modelMeld: bark });
                    break;
                }
            }
            outIn(null, index, index2);
        } else {
            handModel.remove(index - (bark.type === 4 ? 2 : 1),
                             bark.type === 4 ? 3 : 2);
        }

        if (!bark.isKakan) {
            barksModel.append({ modelMeld: bark, modelFloatAct: "",
                                  modelFloatArg: -1, modelIndex: -1 });
        }
    }

    function setBarks(barks) {
        barksModel.clear();
        for (var i = 0; i < barks.length; i++)
            barksModel.append({ modelMeld: barks[i], modelFloatAct: "",
                                  modelFloatArg: -1, modelIndex: -1 });
    }

    function insertDrawn(inPos) {
        var drawnModel = {
            modelTileStr: drawn.tileStr,
            modelLay: false, modelDark: drawn.dark,
            modelClickable: drawn.clickable,
            modelFloatAct: "", modelFloatArg: -1
        };
        handModel.insert(inPos, drawnModel);
        drawn.tileStr = "hide";
    }

    function easyPass() {
        if (frame.can.tsumokiri)
            frame.actionTriggered("SPIN_OUT", -1);
        else if (frame.can.pass)
            frame.actionTriggered("PASS", -765);
        // else do nothing
    }
} // end of Item

