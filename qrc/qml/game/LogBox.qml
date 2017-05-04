import QtQuick 2.7
import "../widget"
import "../js/spell.js" as Spell

Rectangle {
    id: logBox

    property int fontSize

    color: "#AA000000"
    // width set by parent
    height: msg.height + fontSize * 1.5
    visible: false

    Texd {
        id: msg
        anchors.centerIn: parent
        wrapMode: TextEdit.WrapAnywhere
        horizontalAlignment: Text.AlignHCenter
        focus: true
        text: ""
        color: "white"
        font.pixelSize: fontSize
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            logBox.clear();
        }
    }

    function log(str) {
        if (msg.text !== "")
            msg.text += "\n";
        msg.text += Spell.logtr(str);
        visible = true;
    }

    function clear() {
        msg.text = "";
        logBox.visible = false;
    }
}
