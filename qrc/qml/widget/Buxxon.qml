import QtQuick 2.7
import QtMultimedia 5.7


Item {
    id: frame

    signal clicked

    property url image
    property string text
    property color textColor: global.color.text
    property color lightColor: global.color.light
    property bool enabled: true
    property real textLength: 4.0
    property int fontSize: global.size.middleFont
    property SoundEffect sound: global.sound.button

    width: textLength * fontSize
    height: width + 1.5 * fontSize
    opacity: enabled ? 1.0 : 0.5

    MouseArea {
        id: mouseArea
        enabled: frame.enabled
        hoverEnabled: true
        anchors.fill: parent
        onClicked: {
            sound.play();
            frame.clicked();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: global.color.back
        radius: global.size.space
        border.width: Math.max(0.2 * global.size.space, 1)
        border.color: global.color.text

        transform: Scale {
            origin.x: width / 2
            origin.y: height / 2
            xScale: mouseArea.containsPress ? 0.9 : 1
            yScale: mouseArea.containsPress ? 0.9 : 1
        }

        // hover highlight
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: frame.lightColor
            visible: global.mobile ? mouseArea.containsPress : mouseArea.containsMouse
        }

        Image {
            width: 0.9 * frame.width
            height: width
            source: frame.image
        }

        Texd {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: global.size.space
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: frame.fontSize
            horizontalAlignment: Text.AlignHCenter
            color: frame.textColor
            text: frame.text
        }
    }
}
