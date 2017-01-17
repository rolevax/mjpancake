import QtQuick 2.0
import "widget"

Row {
    id: actionButtonBar

    property int buttonHeight

    signal actionTriggered(string actStr)

    spacing: global.size.space

    Repeater {
        id: repeater
        model: []

        ActionButton {
            act: modelData
            height: buttonHeight
            mouseArea.onClicked: _cb(act);
        }
    }

    function _cb(act) { // must seperate-out a function to avoid ref error
        actionButtonBar.actionTriggered(act);
    }

    function add(act) {
        repeater.model = repeater.model.concat(act);
    }

    function clear() {
        repeater.model = [];
    }
}
