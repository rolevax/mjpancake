import QtQuick 2.0

Item {
    property bool animEnabled: true
    property string tileSet: "std"
    property int tw
    readonly property int maxExtra: 4

    id: river
    width: tw * 6 + tw * maxExtra
    height: 1.35 * tw * 3

    property int count: 0

    ListModel { id: model1 }
    ListModel { id: model2 }
    ListModel { id: model3 }

    Column {
        RiverRow {
            id: row1
            animEnabled: river.animEnabled
            tileSet: river.tileSet
            tw: river.tw
            model: model1
        }

        RiverRow {
            id: row2
            animEnabled: river.animEnabled
            tileSet: river.tileSet
            tw: river.tw
            model: model2
        }

        RiverRow {
            id: row3
            animEnabled: river.animEnabled
            tileSet: river.tileSet
            tw: river.tw
            width: tw * (6 + maxExtra);
            model: model3
        }
    }

    function clear() {
        clearCircles();
        model1.clear();
        model2.clear();
        model3.clear();
        river.count = 0;
    }

    function set(tiles) {
        var i;

        clear();

        for (i = 0; i < tiles.length && i < 6; i++)
            model1.append(tiles[i]);
        for (i = 6; i < tiles.length && i < 12; i++)
            model2.append(tiles[i]);
        for (i = 12; i < tiles.length; i++)
            model3.append(tiles[i]);

        count = tiles.length;
    }

    function add(tile, outCoord) {
        if (count < 6) {
            row1.outCoord = mapToItem(row1, outCoord.x, outCoord.y);
            model1.append(tile);
        } else if (count < 12) {
            row2.outCoord = mapToItem(row2, outCoord.x, outCoord.y);
            model2.append(tile);
        } else {
            row3.outCoord = mapToItem(row3, outCoord.x, outCoord.y);
            model3.append(tile);
        }
        count++;
    }

    function sub() {
        if (count <= 6)
            model1.remove(count - 1, 1);
        else if (count <= 12)
            model2.remove(count - 7, 1);
        else
            model3.remove(count - 13, 1);
        count--;
    }

    function showCircle(flash) {
        if (count <= 6) {
            row1.showCircle = true;
            row1.flashCircle = flash;
        } else if (count <= 12) {
            row2.showCircle = true;
            row2.flashCircle = flash;
        } else {
            row3.showCircle = true;
            row3.flashCircle = flash;
        }
    }

    function clearCircles() {
        row1.showCircle = false;
        row2.showCircle = false;
        row3.showCircle = false;
    }
}

