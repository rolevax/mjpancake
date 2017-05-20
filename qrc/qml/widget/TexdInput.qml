import QtQuick 2.7
import rolevax.sakilogy 1.0

Rectangle {
    id: frame

    property string hintText
    property real textLength: 4.0
    property int fontSize: global.size.middleFont
    property var tabTo
    property bool number: false

    property alias echoMode: input.echoMode
    property alias validator: input.validator
    property alias acceptableInput: input.acceptableInput
    property alias enabled: input.enabled
    property alias text: input.text

    signal accepted

    width: textLength * fontSize
    height: 1.5 * fontSize
    color: PGlobal.themeBack
    border.width: 0.03 * height
    border.color: PGlobal.themeText
    opacity: enabled ? 1.0 : 0.5

    Texd {
        visible: input.text.length === 0
        text: hintText
        font.pixelSize: fontSize
        anchors.centerIn: parent
        opacity: 0.5
    }

    TextInput {
        id: input
        anchors.fill: parent
        font.pixelSize: fontSize
        horizontalAlignment: TextInput.AlignHCenter
        color: PGlobal.themeText
        focus: false
        font.family: wqy.name
        inputMethodHints: number ? Qt.ImhDigitsOnly : Qt.ImhNoAutoUppercase
        onAccepted: {
            if (acceptableInput)
                frame.accepted();
        }
    }

    FontLoader { id: wqy; source: "/font/wqy-microhei.ttf" }


    onFocusChanged: {
        if (focus)
            input.focus = true;
    }

    function removeFocus() {
        input.focus = false;
    }
}


