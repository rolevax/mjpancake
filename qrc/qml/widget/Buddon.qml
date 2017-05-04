import QtQuick 2.7
import QtMultimedia 5.7

Rectangle {
    id: buddon

    signal clicked
    property string text
    property color textColor: "white"
    property color lightColor: "#16FFFFFF"
    property bool smallFont: false
    property bool enabled: true
    property real textLength: 4.0
    property int fontSize: smallFont ? global.size.smallFont : global.size.middleFont
    property SoundEffect sound: global.sound.button

    width: textLength * fontSize
    height: 1.5 * fontSize
    color: "#333344"
    opacity: enabled ? 1.0 : 0.5
    border.width: 0.03 * height
    border.color: "white"

    Rectangle {
        anchors.fill: parent
        color: buddon.lightColor
        radius: parent.radius
        visible: global.mobile ? mouseArea.containsPress : mouseArea.containsMouse
    }

    MouseArea {
        id: mouseArea
        enabled: buddon.enabled
        hoverEnabled: true
        anchors.fill: parent
        onClicked: {
            sound.play();
            buddon.clicked();
        }
    }

    Texd {
        id: texd
        anchors.centerIn: parent
        font.pixelSize: buddon.fontSize
        color: buddon.textColor
        text: buddon.text
    }
}


