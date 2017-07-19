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
    border.width: Math.max(0.2 * global.size.space, 1)
    border.color: "white"

    transform: Scale {
        origin.x: width / 2
        origin.y: height / 2
        xScale: mouseArea.containsPress ? 0.95 : 1
        yScale: mouseArea.containsPress ? 0.9 : 1
    }

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


