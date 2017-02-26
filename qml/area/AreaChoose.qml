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
                spacing: global.size.space
                width: 0.3 * frame.height

                Texd {
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: global.size.middleFont
                    text: users[index] ? users[index].Username + "\n" +
                                         NetTrans.level(users[index].Level) +
                                         NetTrans.rating(users[index].Rating) + "\n"
                                       : ""
                }

                Texd {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: global.size.middleFont
                    visible: !(index === 0 && _buttonVisible)
                    opacity: index === 0 && _girlIndex !== 0 ? 0.5 : 1.0
                    text: choices ? Names.names[choices[2 * index + 0]] : ""
                }

                Texd {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: global.size.middleFont
                    visible: !(index === 0 && _buttonVisible)
                    opacity: index === 0 && _girlIndex !== 1 ? 0.5 : 1.0
                    text: choices ? Names.names[choices[2 * index + 1]] : ""
                }

                Buzzon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    textLength: 8
                    text: choices ? Names.names[choices[2 * index + 0]] : ""
                    visible: _buttonVisible && index === 0
                    onClicked: { _clickChoose(0) }
                }

                Buzzon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    textLength: 8
                    text: choices ? Names.names[choices[2 * index + 1]] : ""
                    visible: _buttonVisible && index === 0
                    onClicked: { _clickChoose(1); }
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

    function splash() {
        _buttonVisible = true;
        _girlIndex = -1;
        frame.visible = true;
        timeBar.timeDown();
    }
}
