import QtQuick 2.7
import rolevax.sakilogy 1.0

Item {
    id: frame

    property var doraIndic: []
    property string tileSet: "std"
    property color backColor: PGlobal.backColors[0]
    property real tw

    width: 5 * tw
    height: 1.35 * tw

    Row {
        Repeater {
            id: rep
            model: 5
            Tile {
                tileSet: frame.tileSet
                tileStr: doraIndic && doraIndic[4 - index] ? doraIndic[4 - index] : "back"
                tileWidth: tw
                backColor: frame.backColor
            }
        }
    }
}

