import QtQuick 2.0
import rolevax.sakilogy 1.0
import "../widget"

Rectangle {
    signal closed

    property int backButtonZ: 0

    anchors.fill: parent
    color: PGlobal.themeBack

    MouseArea {
        // prevent click piercing
        anchors.fill: parent
        propagateComposedEvents: false
        onClicked: {
            PGlobal.forceImmersive();
        }
    }

    Buzzon {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: global.size.space
        z: backButtonZ
        textLength: 8
        text: "返回"
        onClicked: { closed(); }
    }

    focus: true
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            cancelHandler();
            event.accepted = true;
        }
    }

    function cancelHandler() {
        closed();
    }
}
