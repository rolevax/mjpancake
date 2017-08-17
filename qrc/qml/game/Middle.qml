import QtQuick 2.7
import "../widget"

Rectangle {
    id: middle

    color: "#77AAAACC"

    signal diceRolled

    property bool animEnabled: true
    property int prevRound: 0 // used for displaying prefix "流れ"
    property int dealer: -1 // use '-1' to ensure onDealerChange() called
    property int die1: 0
    property int die2: 0
    property int wallRemain
    readonly property bool pointed: global.mobile ? mouseArea.containsPress
                                                  : mouseArea.containsMouse

    Column {
        anchors.centerIn: parent
        spacing: 2 * global.size.space

        Texd {
            id: roundText
            property bool blinking: false
            font.pixelSize: middle.width / (global.mobile ? 8 : 9)
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "black"
            SequentialAnimation on opacity {
                id: flashAnim
                PropertyAnimation { to: 0.2; duration: 500 }
                PropertyAnimation { to: 1.0; duration: 500 }
                loops: Animation.Infinite
                running: roundText.blinking
            }
            onBlinkingChanged: { if (!blinking) roundText.opacity = 1.0; }
        }

        Texd {
            x: (parent.width - width) / 2
            id: remainText
            font.pixelSize: middle.width / (global.mobile ? 8 : 9)
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "black"
        }
    }

    Repeater {
        id: repeater
        model: 4
        delegate: MiddleNameBar {
            showPointDiff: middle.pointed
            animEnabled: middle.animEnabled
            x: (middle.width - width) / 2
            y: middle.height - height - 2 * global.size.space
            tw: middle.width / 6
            transform: Rotation {
                angle: -90 * index
                origin.x: width / 2
                origin.y: 2 * global.size.space + height - middle.height / 2
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
    }

    ActionButton {
        id: diceButton
        act: "DICE"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: parent.height / 18
        height: 0.15 * middle.height
        visible: false
        onClicked: {
            diceButton.visible = false;
            middle.diceRolled();
        }
    }

    onWallRemainChanged: {
        if (wallRemain === 122) {
            remainText.text = "";
        } else {
            remainText.text = _diceStr() + " " + wallRemain;
        }
    }

    function reset() {
        removeBars();
        setPoints([ 0, 0, 0, 0 ]);
        for (var i = 0; i < 4; i++) {
            repeater.itemAt(i).seatText.text = "";
        }

        prevRound = 0;
        dealer = -1;
        die1 = 0;
        die2 = 0;
        roundText.text = "";
        remainText.text = "";
    }

    function setDealer(d, isTemp) {
        dealer = d;
        var val = isTemp ? ["仮", "", "", ""] : ["東", "南", "西", "北"];
        for (var i = 0; i < 4; i++) {
            var index = (dealer + i) % 4;
            repeater.itemAt(index).seatText.text = val[i];
        }
    }

    function setRound(round, extra) {
        var wind = ["東", "南", "西", "北"];
        var num = ["一", "二", "三", "四", "五", "六", "七", "八", "⑨", "十",
                "十一", "十二", "十三", "十四", "十五", "十六",
                "十七", "十八", "十⑨", "二十"];
        var str = wind[Math.floor(round / 4)] + num[round % 4] + "局";
        if (extra !== 0) {
            str += "\n";
            if (round !== prevRound)
                str += "流れ";
            str += (num[extra - 1] ? num[extra - 1] : extra) + "本場";
        }

        prevRound = round;
        roundText.text = str;

        if (animEnabled)
            roundText.blinking = true;
    }

    function setPoints(points) {
        for (var i = 0; i < 4; i++) {
            repeater.itemAt(i).point = points[i];
            repeater.itemAt(i).myPoint = points[0];
        }
    }

    function addBar(who) {
        repeater.itemAt(who).addBar();
    }

    function removeBars() {
        for (var i = 0; i < 4; i++) {
            repeater.itemAt(i).removeBars();
        }
    }

    function activateDice() {
        diceButton.visible = true;
    }

    function deactivate() {
        diceButton.visible = false;
    }

    function setDice(die1, die2) {
        roundText.blinking = false;
        middle.die1 = die1;
        middle.die2 = die2;
        diceAnim.start();
    }

    function _diceStr() {
        var dice = die1 + die2;
        var diceStr = ["自", "右", "対", "左"][(dice - 1) % 4] + dice;
        return diceStr;
    }

    SequentialAnimation {
        id: diceAnim

        property int r1: 0
        property int r2: 0

        function updateText(i1, i2) {
            var diceSize = Math.floor(1.4 * global.size.middleFont);
            var img1 = "<img width=\"" + diceSize + "\" height=\"" + diceSize + "\" " +
                    "src=\"qrc:///pic/dice/dice" + i1 + ".png\" />";
            var img2 = "<img width=\"" + diceSize + "\" height=\"" + diceSize + "\" " +
                    "src=\"qrc:///pic/dice/dice" + i2 + ".png\" />";
            remainText.text = img1 + img2;
        }

        SequentialAnimation {
            ScriptAction {
                script: {
                    var next;
                    do {
                        next = Math.floor(Math.random() * 6) + 1;
                    } while (next === diceAnim.r1);
                    diceAnim.r1 = next;
                    do {
                        next = Math.floor(Math.random() * 6) + 1;
                    } while (next === diceAnim.r2);
                    diceAnim.r2 = next;
                    diceAnim.updateText(diceAnim.r1, diceAnim.r2);
                }
            }

            PauseAnimation { duration: 100 }
            loops: animEnabled ? 10 : 0
        }

        ScriptAction {
            script: {
                diceAnim.updateText(middle.die1, middle.die2);
            }
        }
    }
}

