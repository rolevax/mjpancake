import QtQuick 2.0

Rectangle {
    id: buddon

    signal clicked
    property string text
    property color textColor: "white"
    property color lightColor: "#16FFFFFF"
    property bool smallFont: false
    property real textLength: 4.0
    property int fontSize: smallFont ? global.size.smallFont : global.size.middleFont

    width: textLength * fontSize
    height: 1.5 * fontSize
    color: "#333344"
    border.width: 0.03 * height
    border.color: "white"

    Rectangle {
        anchors.fill: parent
        color: buddon.lightColor
        radius: parent.radius
        visible: mouseArea.containsMouse
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        onClicked: {
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


