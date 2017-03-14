import QtQuick 2.7
import rolevax.sakilogy 1.0

Item {
    id: frame

    signal clicked

    property string tileSet: "std"
    property color backColor: PGlobal.backColors[0]
    property real tw

    property int dealer: 0
    property int dice: 2
    property int frontRemain: 122
    property int backRemain: 4
    property var doraIndics: []

    width: 17 * tw
    height: width

    Repeater {
        model: 4

        Row {
            property int wallIndex: index

            layoutDirection: Qt.RightToLeft
            anchors.top: parent.bottom
            anchors.left: parent.left

            Repeater {
                model: 17

                Tile {
                    property int tileIndex: index

                    opacity: _tileVisible(wallIndex, tileIndex)
                    y: -tw
                    tileSet: frame.tileSet
                    tileStr: _tileStr(wallIndex, tileIndex)
                    tileWidth: tw
                    backColor: frame.backColor

                    Rectangle {
                        visible: _tileHalf(wallIndex, tileIndex)
                        anchors.fill: parent
                        opacity: 0.3
                        color: "black"
                    }
                }
            }

            Item {
                width: tw
                height: width
            }

            transform: Rotation {
                origin.x: frame.width / 2
                origin.y: -frame.height / 2
                angle: index * 90
            }
        }
    }

    SequentialAnimation {
        id: animDeal

        SequentialAnimation {
            ScriptAction { script: { frontRemain -= 4; } }
            PauseAnimation { duration: 100 }
            loops: 12
        }

        SequentialAnimation {
            ScriptAction { script: { frontRemain--; } }
            PauseAnimation { duration: 100 }
            loops: 4
        }
    }

    PropertyAnimation {
        id: animOpa
        target: frame
        property: "opacity"
        from: 0
        to: 1
        duration: 100
    }

    transform: Rotation {
        origin.x: frame.width / 2
        origin.y: frame.height / 2
        angle: -90 * (dealer + (dice - 1) % 4) - 1
    }

    function _catchPos(wallIndex, tileIndex) {
        var catchPos = tileIndex - dice + 17 * wallIndex;
        if (catchPos < 0)
            catchPos += 68;
        return catchPos;
    }

    function _tileVisible(wallIndex, tileIndex) {
        if (frontRemain === 122)
            return true;

        var catchPos = _catchPos(wallIndex, tileIndex);

        if (catchPos === 0) // 1st rinshan
            return frontRemain < 70 && backRemain === 4;
        else if (catchPos === 67) // 2nd rinshan
            return backRemain >= 3;
        else if (catchPos === 66) // 3rd and 4th rinshan
            return backRemain >= 1;
        else if (61 <= catchPos && catchPos <= 65) // drids
            return true;
        else
            return frontRemain >= 122 - 2 * catchPos - 1;
    }

    function _tileHalf(wallIndex, tileIndex) {
        if (frontRemain === 122)
            return false;

        var catchPos = _catchPos(wallIndex, tileIndex);

        if (catchPos === 0 || catchPos === 67) // 1st and 2nd rinshan
            return frontRemain < 70;
        else if (catchPos === 66) // 3rd and 4th rinshan
            return backRemain === 1;
        else if (61 <= catchPos && catchPos <= 65) // drids
            return false;
        else
            return frontRemain === 122 - 2 * catchPos - 1;
    }

    function _tileStr(wallIndex, tileIndex) {
        var catchPos = _catchPos(wallIndex, tileIndex);
        if (61 <= catchPos && catchPos <= 65) {
            var i = 4 - (catchPos - 61);
            return i < doraIndics.length ? doraIndics[i] : "back";
        } else {
            return "back";
        }
    }

    function flip(newIndic) {
        doraIndics.push(newIndic);
        doraIndicsChanged();
    }

    function clear() {
        doraIndics = [];
        frontRemain = 122;
        backRemain = 4;
        animOpa.start();
    }

    function deal() {
        animDeal.start();
    }
}
