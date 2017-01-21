import QtQuick 2.0
import "../widget"

Rectangle {
    id: actionButton

    property string act
    property alias mouseArea: mouseArea

    width: 2.67 * height
    height: global.size.middleFont
    color: mouseArea.containsMouse ? "#FFFF00" : "#99FFFF00"

    function _actionText(act) {
        var val = {
            TSUMO: "♀", RON: "♂", PASS: "▶", RIICHI: "！", RYUUKYOKU: "~",
            DICE: "@", IRS_CLICK: "+", IRS_RIVAL: "X"
        };
        return val[act];
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
    }

    Texd {
        id: text
        anchors.centerIn: parent
        font.pixelSize: actionButton.height
        text: _actionText(actionButton.act)
        color: "black"
    }
}

