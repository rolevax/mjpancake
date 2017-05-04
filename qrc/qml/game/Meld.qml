import QtQuick 2.7

Item {
    id: frame

    property string tileSet: "std"
    property color backColor
    property int tw

    // most cases, special cases will be set specially
    width: 2 * tw + 1.35 * tw
    height: 1.35 * tw

    property var meld

    Tile {
        id: left
        tileSet: frame.tileSet
        tileWidth: tw
        tileStr: "hide"
        backColor: frame.backColor
    }

    Tile {
        id: middle
        tileSet: frame.tileSet
        tileWidth: tw
        anchors.left: left.right
        anchors.bottom: left.bottom
        tileStr: "hide"
        backColor: frame.backColor
    }

    Tile {
        id: right
        tileSet: frame.tileSet
        tileWidth: tw
        anchors.left: middle.right
        anchors.bottom: middle.bottom
        tileStr: "hide"
        backColor: frame.backColor
    }

    Tile {
        id: extra
        tileSet: frame.tileSet
        tileWidth: tw
        tileStr: "hide"
        backColor: frame.backColor
    }

    onMeldChanged: {
        if (meld) {
            var lt = meld.type === 1 ? meld[meld.open] : meld[0];
            var mt = meld.type === 1 && 0 !== meld.open ? meld[0] : meld[1];
            var rt = meld.type === 1 && 2 === meld.open ? meld[1] : meld[2];
            var et = meld[3] ? meld[3] : "hide";

            left.tileStr = lt.substring(0, 2);
            middle.tileStr = mt.substring(0, 2);
            right.tileStr = rt.substring(0, 2);

            left.lay = lt[2] === "_";
            middle.lay = mt[2] === "_";
            right.lay = rt[2] === "_";

            if (meld.type === 4) {
                extra.tileStr = et.substring(0, 2);
                extra.lay = et[2] === "_";
            }

            if (meld.isDaiminkan) {
                extra.anchors.left = middle.right;
                extra.anchors.bottom = left.bottom;
                right.anchors.left = extra.right;
                frame.width = 3 * tw + 1.35 * tw;
            } else if (meld.isKakan) {
                var base = meld.open === 0 ? left : (meld.open === 1) ? middle : right;
                extra.anchors.left = base.left;
                extra.y = -tw;
            } else if (meld.isAnkan) {
                extra.anchors.left = right.right;
                extra.anchors.bottom = left.bottom;
                left.tileStr = "back";
                extra.tileStr = "back";
                frame.width = 4 * tw;
            }
        } else {
            left.tileStr = "hide";
            middle.tileStr = "hide";
            right.tileStr = "hide";
            extra.tileStr = "hide";
        }
    }
}

