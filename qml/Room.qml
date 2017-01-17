import QtQuick 2.0
import QtQuick.Controls 1.2
import rolevax.sakilogy 1.0
import "widget"

Rectangle {
    signal closed

    anchors.fill: parent
    color: PGlobal.themeBack

    MouseArea {
        // prevent click piercing
        anchors.fill: parent
        propagateComposedEvents: false
    }

    Buzzon {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: global.size.space
        textLength: 8
        text: "返回"
        onClicked: { closed(); }
    }

    focus: true
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape
                || event.key === Qt.Key_Back) {
            cancelHandler();
            event.accepted = true;
        }
    }

    function cancelHandler() {
        closed();
    }
}
