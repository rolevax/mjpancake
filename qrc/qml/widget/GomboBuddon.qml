import QtQuick 2.7
import rolevax.sakilogy 1.0

Rectangle {
    id: buddon

    signal clicked
    property string text

    color: global.color.back

    Rectangle {
        anchors.fill: parent
        color: global.color.light
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

