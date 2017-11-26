import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/nettrans.js" as NetTrans
import "../js/girlnames.js" as Names
import "../game"
import "../widget"

Rectangle {
    id: frame

    property var choices: null
    property bool _buttonVisible: true
    property int _girlIndex: -1

    signal chosen(int girlIndex)

    anchors.fill: parent
    color: global.color.back
    visible: false

    Column {
        id: mainRow
        // FUCK change to row of photos
        anchors.centerIn: parent
        spacing: global.size.space
        width: 0.3 * frame.height

        Repeater {
            model: 3
            delegate: Buzzon {
                anchors.horizontalCenter: parent.horizontalCenter
                textLength: 8
                text: choices ? Names.names[choices[index]] : ""
                visible: _buttonVisible
                onClicked: { _clickChoose(index) }
            }
        }
    }

    TimeBar {
        id: timeBar
        anchors.left: mainRow.left
        anchors.right: mainRow.right
        anchors.top: mainRow.bottom
        onFired: {
            chosen(0);
        }
    }

    function _clickChoose(girlIndex) {
        timeBar.cancel();

        _buttonVisible = false;
        _girlIndex = girlIndex;

        chosen(girlIndex);
    }

    function _userIntro(user) {
        var res = user.Username + "\n" + NetTrans.level(user.Level);
        if (user.Rating >= 1800.0)
            res += " " + NetTrans.rating(user.Rating);
        res += "\n";
        return res;
    }

    function splash() {
        global.sound.bell.play();
        _buttonVisible = true;
        _girlIndex = -1;
        frame.visible = true;
        timeBar.timeDown();
    }
}
