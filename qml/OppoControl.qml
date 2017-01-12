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
        property string tileStr
        id: drawnStand
        visible: false
        tileSet: frame.tileSet
        backColor: frame.backColor
        width: frame.tw
        x: stand.x + stand.width + 10

        PropertyAnimation on y {
            id: animDraw
            from: -50
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
        anchors.top: drawnStand.top
        anchors.left: drawnStand.left
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

    function deal(init) {
        stand.model = []; // use 'populate' transition
        for (var i in init) {
            standModel.append({});
            handModel.append(init[i]);
        }
        stand.model = standModel;

        drawnStand.visible = false;
        if (!keepOpen) {
            frame.stand = true;
        } else {
            frame.stand = false;
            frame.show = true;
        }
    }

    function draw(tile) {
        drawnStand.tileStr = tile.modelTileStr;

        if (keepOpen) {
            drawnTile.tileStr = tile.modelTileStr;
            drawnTile.visible = true;
        } else {
            drawnStand.visible = true;
        }

        if (frame.animEnabled)
            animDraw.start();
    }

    function outIn(tile, outPos, inPos) {
        var res;

        if (outPos !== 13) {
            var randPos = Math.floor(Math.random() * standModel.count);
            res = mapFromItem(frame, randPos * tw, 0);
            standModel.remove(randPos, 1);
            handModel.remove(outPos, 1);
            if (inPos >= 0) { // insert drawn into hand
                insertDrawn(inPos);
            }
        } else {
            res = mapFromItem(drawnStand, 0, 0);
        }

        drawnStand.tileStr = "hide";
        drawnStand.visible = false;
        drawnTile.visible = false;

        return res;
    }

    function outBark(index, index2, bark) {
        var randPos;
        if (bark.type === 1) { // chii
            randPos = Math.floor(Math.random() * (standModel.count - 1));
            standModel.remove(randPos, 2);

            handModel.remove(index2, 1);
            handModel.remove(index, 1);
        } else if (bark.isAnkan) {
            if (index2 >= 0) {
                randPos = Math.floor(Math.random() * (standModel.count - 3));
                standModel.remove(randPos, 4);

                handModel.remove(index - 2, 4);
                insertDrawn(index2);
            } else {
                randPos = Math.floor(Math.random() * (standModel.count - 2));
                standModel.remove(randPos, 3);

                handModel.remove(index - 2, 3);
                drawnStand.tileStr = "hide";
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
        } else { // daiminkan or pon
            var removeCt = bark.type === 4 ? 3 : 2;
            randPos = Math.floor(Math.random() *
                                 (standModel.count - (removeCt - 1)));
            standModel.remove(randPos, removeCt);

            handModel.remove(index - (removeCt - 1), removeCt);
        }

        if (!bark.isKakan) {
            barksModel.append({ modelMeld: bark });
        }
    }

    function setBarks(barks) {
        barksModel.clear();
        for (var i = 0; i < barks.length; i++)
            barksModel.append({ modelMeld: barks[i] });
    }

    function insertDrawn(inPos) {
        var drawnModel = {
            modelTileStr: drawnStand.tileStr,
            modelLay: false,
            modelDark: false,
            modelClickable: false
        };
        handModel.insert(inPos, drawnModel);
        standModel.append({});
        drawnStand.tileStr = "hide";
    }

    function pushDown(show) {
        frame.stand = false;
        frame.show = show;
        if (show && drawnStand.tileStr) {
            drawnTile.tileStr = drawnStand.tileStr;
        }
    }
}

