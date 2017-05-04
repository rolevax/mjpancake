import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/nettrans.js" as NetTrans
import "../js/girlnames.js" as Names
import "../game"
import "../widget"

Rectangle {
    id: frame

    property var users: [ null, null, null, null ]
    property var choices: null
    property bool _buttonVisible: true
    property int _girlIndex: -1

    signal chosen(int girlIndex)

    anchors.fill: parent
    color: PGlobal.themeBack
    visible: false

    Row {
        id: row
        anchors.centerIn: parent
        spacing: global.size.gap

        Repeater {
            id: rep
            model: 4
            delegate: Column {
                property int userIndex: index

                spacing: global.size.space
                width: 0.3 * frame.height

                Texd {
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: global.size.middleFont
                    text: users[index] ? _userIntro(users[index]) : ""
                }

                Repeater {
                    model: 3
                    delegate: Texd {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: global.size.middleFont
                        visible: !(userIndex === 0 && _buttonVisible)
                        opacity: userIndex === 0 && _girlIndex !== index ? 0.5 : 1.0
                        text: choices ? Names.names[choices[3 * userIndex + index]] : ""
                    }
                }

                Repeater {
                    model: 3
                    delegate: Buzzon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        textLength: 8
                        text: choices ? Names.names[choices[3 * userIndex + index]] : ""
                        visible: _buttonVisible && userIndex === 0
                        onClicked: { _clickChoose(index) }
                    }
                }
            }
        }
    }

    TimeBar {
        id: timeBar
        anchors.left: row.left
        anchors.right: row.right
        anchors.top: row.bottom
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
