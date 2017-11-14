import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../game"

Room {
    id: frame

    PParse {
        id: pParse

        onParsed: {
            outputText.blaText = "";
            for (var i in results) {
                if (i > 0)
                    outputText.blaText += "\n";
                outputText.blaText += results[i];
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: global.size.space

            TexdInput {
                id: textInput
                textLength: 24
                onAccepted: {
                    parseButton.clicked();
                }
            }

            Buzzon {
                id: parseButton
                textLength: 4
                text: "="
                onClicked: {
                    try {
                        var ts = _parseMps(textInput.text);
                        tileForm.clear();
                        tileForm.addHand(ts);
                        pParse.parse(ts);
                    } catch (str) {
                        outputText.blaText = str;
                    }
                }
            }

            Buzzon {
                textLength: 2
                text: "AC"
                onClicked: {
                    textInput.text = "";
                    outputText.blaText = "";
                    tileForm.clear();
                }
            }
        }

        TileForm {
            id: tileForm
            anchors.horizontalCenter: parent.horizontalCenter
            z: textInput.z - 1 // somehow blocks input's focus
            tw: 0.05 * frame.height
            backColor: PGlobal.backColors[0]
        }

        Item {
            width: parent.width
            height: frame.height - textInput.height - tileForm.height - 2 * global.size.gap
            visible: !!outputText.blaText

            Rectangle {
                visible: !!outputText.blaText
                anchors.fill: parent
                color: global.color.back
            }

            Fligable {
                id: outputText
                anchors.fill: parent
                anchors.margins: global.size.space
            }
        }
    }

    Component.onCompleted: {
        // somehow robbed by some other item, so rob back
        textInput.focus = true;
    }

    readonly property var _validTiles: [
        "0m", "1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m",
        "0p", "1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p",
        "0s", "1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s",
        "1z", "2z", "3z", "4z", "5z", "6z", "7z",
        "1f", "2f", "3f", "4f",
        "1y", "2y", "3y"
    ]

    function _parseMps(str) {
        var matches = str.match(/[0-9]+[mpsfyzMPSFYZ]/g);
        var res = [];

        for (var i in matches) {
            var match = matches[i];
            for (var j = 0; j + 1 < match.length; j++) {
                res.push(match[j] + match[match.length - 1]);
            }
        }

        if (res.length === 0)
            throw "未输入有效手牌";

        if (res.length > 14)
            throw "大相公";

        if (res.length % 3 === 0)
            throw "手牌张数不自然";

        for (var i in res) {
            if (_validTiles.indexOf(res[i]) < 0)
                throw "非法麻将牌" + res[i];

            // convert tenhou z-syntax to pancake f/y-syntax
            if (res[i][1] === "z") {
                var num = +res[i][0];
                if (num <= 4) {
                    res[i] = num + "f";
                } else {
                    res[i] = (num - 4) + "y";
                }
            }
        }

        return res;
    }
}



