import QtQuick 2.0

Item {
    id: frame

    property var doraIndic: []
    property string tileSet: "std"
    property color backColor
    property real tw

    width: 5 * tw
    height: 1.35 * tw

    Row {
        Repeater {
            id: rep
            model: 5
            Tile {
                tileSet: frame.tileSet
                tileStr: "back"
                tileWidth: tw
                backColor: frame.backColor
            }
        }
    }

    onDoraIndicChanged: {
        var i;
        if (doraIndic && doraIndic.length) { // sometimes not a array, don't know why...
            for (i = 0; i < 5; i++)
                rep.itemAt(4 - i).tileStr = i < doraIndic.length ? doraIndic[i] : "back";
        } else {
            for (i = 0; i < 5; i++)
                rep.itemAt(i).tileStr = "back";
        }
    }
}

