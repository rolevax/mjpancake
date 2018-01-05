import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/nettrans.js" as NetTrans
import "../js/girlnames.js" as Names
import "../game"
import "../widget"

Rectangle {
    id: frame

    property var choices: null
    property var foodCosts: null
    property bool _buttonVisible: true
    property int _girlIndex: -1

    signal chosen(int girlIndex)

    anchors.fill: parent
    color: global.color.back
    visible: false

    Row {
        id: mainRow
        anchors.centerIn: parent
        spacing: global.size.space

        Repeater {
            model: 3
            delegate: Column {
                visible: _buttonVisible

                Texd {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: global.size.middleFont
                    text: choices ? Names.names[choices[index]] : ""
                }

                Buzzon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    textLength: 8
                    text: foodCosts ? foodCosts[index] + "零食" : ""
                    enabled: foodCosts && (foodCosts[index] === 0 || foodCosts[index] <= PClient.user.Food)
                    onClicked: {
                        _clickChoose(index);
                    }
                }
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

    Texd {
        visible: _buttonVisible
        anchors.horizontalCenter: mainRow.horizontalCenter
        anchors.top: timeBar.bottom
        text: "零食库存: " + PClient.user.Food
    }

    Texd {
        visible: !_buttonVisible
        anchors.centerIn: parent
        font.pixelSize: global.size.middleFont
        text: "记者拍照中……"
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
