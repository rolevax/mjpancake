import QtQuick 2.0

Item {
    id: frame

    property bool keepOpen: false
    property bool animEnabled: true
    property bool stand: true
    property bool show: true // meaningful only if 'stand === false'
    property string tileSet: "std"
    property color backColor
    property int tw

    TileStand {
        id: drawnStand
        visible: false
        tileSet: frame.tileSet
        backColor: frame.backColor
        width: frame.tw
        anchors.left: stand.right
        anchors.leftMargin: 0.2 * frame.tw

        PropertyAnimation on y {
            id: animDraw
            from: -frame.tw
            to: 0
            duration: 100
        }
    }

    Tile {
        id: drawnTile
        visible: false
        tileSet: frame.tileSet
        tileWidth: frame.tw
        backColor: frame.backColor
        anchors.left: hand.right
        anchors.leftMargin: 0.2 * frame.tw
    }

    ListModel { id: standModel } // using empty object ({}) as element
    ListModel { id: handModel }

    ListView {
        id: stand
        visible: frame.stand
        x: 0; y: 0
        width: tw * standModel.count; height: 1.35 * tw
        orientation: Qt.Horizontal
        interactive: false
        model: standModel
        delegate: TileStand {
            tileSet: frame.tileSet
            width: frame.tw
            backColor: frame.backColor
        }

        displaced: Transition {
            enabled: frame.animEnabled
            SequentialAnimation {
                PauseAnimation { duration: 300 }
                NumberAnimation {
                    property: "x"
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        add: Transition {
            enabled: frame.animEnabled
            SequentialAnimation {
                NumberAnimation {
                    property: "x"
                    duration: 0
                    to: drawnStand.x
                    easing.type: Easing.InOutQuad
                }
                PauseAnimation { duration: 300 }
                NumberAnimation {
                    property: "x"
                    duration: 300
                    from: drawnStand.x
                    easing.type: Easing.InOutQuad
                }
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
                    from: 13 * tw
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    ListView {
        id: hand
        x: stand.x; y: stand.y; z: 5
        width: tw * handModel.count
        height: 1.35 * tw
        visible: !frame.stand
        orientation: Qt.Horizontal
        interactive: false
        model: handModel
        delegate: Tile {
            tileSet: frame.tileSet
            // the '&& modelTileStr' is to surpress warning in keep-open mode
            tileStr: frame.show && modelTileStr ? modelTileStr : "back"
            tileWidth: tw
            backColor: frame.backColor
        }
    }

    ListView {
        id: barks

        width: parent.width // enough is good
        height: parent.height // enough is good
        anchors.right: frame.right
        anchors.bottom: frame.bottom
        orientation: Qt.Horizontal
        interactive: false
        layoutDirection: Qt.RightToLeft
        spacing: 1
        model: ListModel { id: barksModel }
        delegate: Meld {
            tileSet: frame.tileSet
            tw: frame.tw
            backColor: frame.backColor
            meld: modelMeld
            anchors.bottom: parent.bottom
        }
    }

    function clear() {
        standModel.clear();
        handModel.clear();
        barksModel.clear();
        drawnStand.visible = false;
        drawnTile.visible = false;
    }

    function deal() {
        stand.model = []; // use 'populate' transition
        for (var i = 0; i < 13; i++)
            standModel.append({});
        stand.model = standModel;

        drawnStand.visible = false;
        frame.stand = true;
    }

    function draw(tile) {
        drawnStand.visible = true;

        if (frame.animEnabled)
            animDraw.start();
    }

    function swapOut() {
        var randPos = Math.floor(Math.random() * standModel.count);
        var res = mapFromItem(frame, randPos * tw, 0);
        standModel.remove(randPos, 1);
        if (drawnStand.visible)
            _insertDrawn();
        return res;
    }

    function spinOut() {
        drawnStand.visible = false;
        return mapFromItem(drawnStand, 0, 0);
    }

    function bark(bark, spin) {
        var randPos;
        if (bark.isAnkan) {
            if (spin) {
                randPos = Math.floor(Math.random() * (standModel.count - 2));
                standModel.remove(randPos, 3);
                drawnStand.tileStr = "hide";
            } else {
                randPos = Math.floor(Math.random() * (standModel.count - 3));
                standModel.remove(randPos, 4);
                _insertDrawn();
            }
        } else if (bark.isKakan) {
            for (var i = 0; i < barksModel.count; i++) {
                if (barksModel.get(i).modelMeld[0].modelTileStr ===
                        bark[0].modelTileStr) {
                    barksModel.set(i, { modelMeld: bark });
                    break;
                }
            }
            if (spin)
                spinOut();
            else
                swapOut();
        } else { // chii, pon, daiminkan
            var removeCt = bark.isDaiminkan ? 3 : 2;
            randPos = Math.floor(Math.random() * (standModel.count - (removeCt - 1)));
            standModel.remove(randPos, removeCt);
        }

        if (!bark.isKakan) {
            barksModel.append({ modelMeld: bark });
        }
    }

    function setHand(hand, show) {
        handModel.clear();
        for (var i in hand)
            handModel.append(hand[i]);
    }

    function setDrawn(tile) {
        drawnTile.tileStr = tile.modelTileStr;
        drawnStand.visible = true; // for anchoring
        drawnTile.visible = true;
    }

    function setBarks(barks) {
        barksModel.clear();
        for (var i = 0; i < barks.length; i++)
            barksModel.append({ modelMeld: barks[i] });
    }

    function _insertDrawn() {
        standModel.append({});
        drawnStand.visible = false;
    }

    function pushDown(show, tsumoTile) {
        frame.stand = false;
        frame.show = show;
        if (show && tsumoTile) {
            drawnTile.tileStr = tsumoTile.modelTileStr;
        }
    }
}

