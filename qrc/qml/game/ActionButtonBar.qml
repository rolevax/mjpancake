import QtQuick 2.7
import "../widget"

Row {
    id: actionButtonBar

    signal actionTriggered(string actStr)

    property real buttonHeight
    readonly property bool riichi: riichiToggle.checked

    spacing: global.size.space

    ActionToggle {
        id: riichiToggle
        height: buttonHeight
        visible: false
    }

    Repeater {
        id: repeater
        model: []

        ActionButton {
            act: modelData
            height: buttonHeight
            onClicked: { _cb(act); }
        }
    }

    function _cb(act) { // must seperate-out a function to avoid ref error
        actionButtonBar.actionTriggered(act);
    }

    function addAct(act) {
        repeater.model = repeater.model.concat(act);
    }

    function enableRiichi() {
        riichiToggle.visible = true;
    }

    function clear() {
        repeater.model = [];
        riichiToggle.checked = false;
        riichiToggle.visible = false;
    }
}
