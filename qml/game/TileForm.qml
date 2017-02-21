import QtQuick 2.0

Item {
    id: form

    property string tileSet: "std"
    property color backColor
    property int tw

    width: 0
    height: 1.35 * tw

    ListView {
        id: barks

        width: 19 * tw // big is good
        height: 1.35 * tw
        x: handModel.count * tw + (tw / 6 * 5)
        anchors.bottom: form.bottom
        orientation: Qt.Horizontal
        spacing: 2
        model: ListModel { id: barksModel }
        delegate: Meld {
            tileSet: form.tileSet
            tw: form.tw
            backColor: form.backColor
            meld: modelMeld
            anchors.bottom: parent.bottom
        }
    }

    ListView {
        id: hand
        width: 13 * tw + 1.35 * tw;  // enough is good
        height: 1.35 * tw
        anchors.bottom: parent.bottom
        orientation: Qt.Horizontal
        model: ListModel { id: handModel }

        delegate: Tile {
            tileSet: form.tileSet
            tileWidth: tw
            backColor: form.backColor
            tileStr: modelTileStr
            lay: modelLay
        }
    }

    function clear() {
        handModel.clear();
        barksModel.clear();

        form.width = 20;
    }

    function addHand(hand) {
        for (var i in hand) {
            var model = {
                modelTileStr: hand[i].substr(0, 2),
                modelLay: hand[i][2] === "_"
            };
            handModel.append(model);
        }

        form.width += hand.length * tw;
    }

    function addBarks(barks) {
        barks.reverse();

        for (var i in barks) {
            form.width += tw / 3; // gap
            if (barks[i].isDaiminkan)
                form.width += 3 * tw + 1.35 * tw;
            else if (barks[i].isAnkan)
                form.width += 4 * tw;
            else
                form.width += 2 * tw + 1.35 * tw;

            barksModel.append({ modelMeld: barks[i] });
        }

        if (barks.length > 0)
            form.width -= tw / 3;
    }

    function addPick(pick) {
        var model = { modelTileStr: pick.substr(0, 2), modelLay: true };
        handModel.append(model);
        form.width += 1.35 * tw;
    }
}

