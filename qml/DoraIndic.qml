import QtQuick 2.0

Item {
    id: frame

    property var doraIndic
    property string tileSet: "std"
    property color backColor
    property int tw

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
        for (var i = 0; i < 5; i++)
            rep.itemAt(4 - i).tileStr = doraIndic && i < doraIndic.length ?
                        doraIndic[i].modelTileStr : "back";
    }
}

