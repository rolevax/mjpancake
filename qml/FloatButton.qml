import QtQuick 2.0

Rectangle {
    id: frame

    signal buttonPressed(string actStr, int actArg)

    property string actStr: ""
    property var actArg

    width: 40
    height: 30
    color: mouseArea.containsMouse ? "#FFFF00" : "#99FFFF00"
    visible: actStr !== ""

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: frame.visible
        hoverEnabled: true
        onClicked: {
            buttonPressed(actStr, actArg);
        }
    }

    Texd {
        id: text
        anchors.centerIn: parent
        font.pixelSize: frame.height
        color: "black"
    }

    onActStrChanged: {
        switch (actStr) {
        case "":
            // do nothing
            break;
        case "CHII_AS_LEFT":
        case "CHII_AS_MIDDLE":
        case "CHII_AS_RIGHT":
            text.text = "◀"
            break;
        case "PON":
            text.text = "▼"
            break;
        case "DAIMINKAN":
        case "KAKAN":
        case "ANKAN":
            text.text = "■"
            break;
        default:
            throw "FloatButton: unknown act " + actStr;
        }
    }
}

