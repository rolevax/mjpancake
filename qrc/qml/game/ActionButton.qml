import QtQuick 2.7
import "../widget"

Rectangle {
    id: actionButton

    signal clicked

    property string act
    property bool _light: global.mobile ? mouseArea.containsPress : mouseArea.containsMouse

    width: 2.67 * height
    height: global.size.middleFont
    color: _light ? "#FFFF00" : "#99FFFF00"

    function _actionText(act) {
        var val = {
            TSUMO: "♀", RON: "♂", PASS: "▶", RYUUKYOKU: "~",
            DICE: "@", IRS_CLICK: "+"
        };
        return val[act];
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        onClicked: { actionButton.clicked(); }
    }

    Texd {
        id: text
        anchors.centerIn: parent
        font.pixelSize: actionButton.height
        text: _actionText(actionButton.act)
        color: "black"
    }
}

