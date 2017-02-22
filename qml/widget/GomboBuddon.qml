import QtQuick 2.7
import rolevax.sakilogy 1.0

Rectangle {
    id: buddon

    signal clicked
    property string text

    color: PGlobal.themeBack

    Rectangle {
        anchors.fill: parent
        color: "#44777777"
        visible: mouseArea.containsMouse
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        onClicked: {
            global.sound.button.play();
            buddon.clicked();
        }
    }

    Texd {
        id: texd
        anchors.centerIn: parent
        font.pixelSize: buddon.height / 3 * 2;
        text: buddon.text
    }
}

