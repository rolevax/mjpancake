import QtQuick 2.0
import "widget"
import "spell.js" as Spell

Item {
    id: resultWindow

    property alias doraIndic: doraIndic
    property alias uraIndic: uraIndic
    property string tileSet: "std"
    property color backColor
    property int tw

    property var names: ["A", "B", "C", "D"]

    signal nextRound
    signal endTable

    state: "small"
    visible: false

    states: [
        State {
            name: "small"
            PropertyChanges {
                target: resultWindow
                width: 10 * tw
                height: 10 * tw
            }
            PropertyChanges { target: set1; visible: false }
            PropertyChanges { target: set2; visible: false }
            PropertyChanges { target: doraIndic; visible: false }
            PropertyChanges { target: uraIndic; visible: false }
        },
        State {
            name: "big"
            PropertyChanges {
                target: resultWindow
                width: form.width + 1.35 * tw
                height: 10 * tw
            }
            PropertyChanges { target: set1; visible: true }
            PropertyChanges { target: set2; visible: false }
            PropertyChanges { target: doraIndic; visible: true }
        },
        State {
            name: "huge"
            PropertyChanges {
                target: resultWindow
                width: Math.max(form2.width, form.width) + 1.35 * tw
                height: 16 * tw
            }
            PropertyChanges { target: set1; visible: true }
            PropertyChanges { target: set2; visible: true }
            PropertyChanges { target: doraIndic; visible: true }
        }
    ]

    Column {
        anchors.centerIn: parent
        spacing: 0.55 * tw

        Column {
            id: set2
            Texd {
                id: name2
                visible: set2.visible
                color: "white"
                font.pixelSize: tw / 2
            }

            TileForm {
                id: form2
                tileSet: resultWindow.tileSet
                backColor: resultWindow.backColor
                tw: resultWindow.tw
                visible: set2.visible
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Texd {
            id: text2
            color: "white"
            visible: set2.visible
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 1.35 * tw / 2
        }

        Column {
            id: set1
            Texd {
                id: name
                visible: set1.visible
                color: "white"
                font.pixelSize: tw / 2
            }

            TileForm {
                id: form
                tileSet: resultWindow.tileSet
                backColor: resultWindow.backColor
                tw: resultWindow.tw
                visible: set1.visible
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Texd {
            id: text
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 1.35 * tw / 2
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: tw / 3 * 2

            Buddon {
                id: nextRoundButton
                text: "次局"
                visible: false
                onClicked: {
                    resultWindow.visible = false;
                    resultWindow.nextRound();
                }
            }

            Buddon {
                id: endTableButton
                text: "終了"
                visible: false
                onClicked: {
                    resultWindow.visible = false;
                    resultWindow.endTable();
                }
            }
        }

        Row {
            spacing: tw / 3 * 2
            anchors.horizontalCenter: parent.horizontalCenter

            DoraIndic {
                id: doraIndic;
                tileSet: resultWindow.tileSet
                backColor: resultWindow.backColor
                tw: resultWindow.tw
            }

            DoraIndic {
                id: uraIndic;
                tileSet: resultWindow.tileSet
                backColor: resultWindow.backColor
                tw: resultWindow.tw
            }
        }
    }

    function agari(winners, gunner, hands, forms) {
        state = "big";

        form.clear();
        form.addHand(hands[0].closed);
        form.addBarks(hands[0].barks);
        form.addPick(hands[0].pick);

        text.text = Spell.spell(forms[0].spell);
        text.text += "\n";
        text.text += Spell.charge(forms[0].charge);

        name.text = names[winners[0]];
        if (gunner >= 0)
            name.text += "  <<<  " + names[gunner];

        if (forms.length >= 2) {
            state = "huge";

            form2.clear();
            form2.addHand(hands[1].closed);
            form2.addBarks(hands[1].barks);
            form2.addPick(hands[1].pick);

            text2.text = Spell.spell(forms[1].spell);
            text2.text += "\n";
            text2.text += Spell.charge(forms[1].charge);

            name2.text = names[winners[1]];
            name2.text += "  <<<  " + names[gunner];
        }

        uraIndic.visible = uraIndic.doraIndic.length > 0;
        visible = true;
    }

    function ryuukyoku(type) {
        var dict = {
            HP: "流局", KSKP: "九種九牌", SFRT: "四風連打",
            SKSR: "四槓散了", SCRC: "四家立直", SCHR: "三家和了",
            NGSMG: "流し満貫"
        };

        state = "small";
        text.text = "\n\n" + dict[type];

        visible = true;
    }

    function activate(action) {
        nextRoundButton.visible = !!action.NEXT_ROUND;
        endTableButton.visible = !!action.END_TABLE;
    }
}

