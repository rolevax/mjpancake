import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../game"
import "../js/spell.js" as Spell

Room {
    id: frame

    property int fuHanIndex: 0
    property int selfWind: 1
    property int roundWind: 1
    property bool ron: false

    property var fuHan: [
        [
            [20, 2], [20, 3], [20, 4],
            [30, 1], [30, 2], [30, 3], [30, 4],
            [40, 1], [40, 2], [40, 3], [50, 1], [50, 2], [50, 3],
            [60, 1], [60, 2], [60, 3],
            [70, 1], [70, 2], [80, 1], [80, 2], [90, 1], [90, 2],
            [100, 1], [100, 2], [110, 2],
            [0, 3], [0, 4], [0, 5], [0, 6], [0, 7], [0, 8], [0, 9],
            [0, 10], [0, 11], [0, 12], [0, 13]
        ],
        [
            [30, 1], [30, 2], [30, 3], [30, 4],
            [40, 1], [40, 2], [40, 3], [50, 1], [50, 2], [50, 3],
            [60, 1], [60, 2], [60, 3],
            [70, 1], [70, 2], [80, 1], [80, 2], [90, 1], [90, 2],
            [100, 1], [100, 2], [110, 1], [110, 2],
            [0, 3], [0, 4], [0, 5], [0, 6], [0, 7], [0, 8], [0, 9],
            [0, 10], [0, 11], [0, 12], [0, 13]
        ]
    ]

    property var fuHanString: [
        [
            "20符2飜", "20符3飜", "20符4飜",
            "30符1飜", "30符2飜", "30符3飜", "30符4飜",
            "40符1飜", "40符2飜", "40符3飜", "50符1飜", "50符2飜", "50符3飜",
            "60符1飜", "60符2飜", "60符3飜",
            "70符1飜", "70符2飜", "80符1飜", "80符2飜", "90符1飜", "90符2飜",
            "100符1飜", "100符2飜", "110符2飜",
            "3飜満貫", "4飜満貫", "5飜満貫", "6飜跳満", "7飜跳満",
            "8飜倍満", "9飜倍満", "10飜倍満",
            "11飜三倍満", "12飜三倍満","13飜数え役満"
        ],
        [
            "30符1飜", "30符2飜", "30符3飜", "30符4飜",
            "40符1飜", "40符2飜", "40符3飜", "50符1飜", "50符2飜", "50符3飜",
            "60符1飜", "60符2飜", "60符3飜",
            "70符1飜", "70符2飜", "80符1飜", "80符2飜", "90符1飜", "90符2飜",
            "100符1飜", "100符2飜", "110符1飜", "110符2飜",
            "3飜満貫", "4飜満貫", "5飜満貫", "6飜跳満", "7飜跳満",
            "8飜倍満", "9飜倍満", "10飜倍満",
            "11飜三倍満", "12飜三倍満","13飜数え役満"
        ]
    ]

    PGen {
        id: pGen

        onGenned: {
            form.clear();

            form.addHand(how.hand);
            form.addBarks(how.barks);
            form.addPick(how.pick);

            text.text = Spell.spell(how.spell);
            text.text += "\n";
            text.text += Spell.charge(how.charge);
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 2 * global.size.space

        Row {
            z: form.z + 1
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: global.size.space

            GomboMenu {
                model: fuHanString[ron ? 1 : 0]
                buddon.width: global.mobile ? 180 : 130
                buddon.height: ronGombo.buddon.height
                onActivated: {
                    fuHanIndex = index;
                }
            }

            GomboMenu {
                model: [ "自風東", "自風南", "自風西", "自風北" ]
                onActivated: { selfWind = index + 1; }
            }

            GomboMenu {
                model: [ "場風東", "場風南", "場風西", "場風北" ]
                onActivated: { roundWind = index + 1; }
            }

            GomboToggle {
                id: ronGombo
                model: [ "自摸", "栄和" ]
                onActivated: { ron = (index === 1); }
            }
        }

        TileForm {
            id: form
            tw: frame.height / 20
            backColor: PGlobal.backColors[0]
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Texd {
            id: text
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            height: 3 * global.size.middleFont
            font.pixelSize: global.size.middleFont
            color: global.color.text
            text: ""
            shade: true
            shadePaddings: global.size.space
        }

        Buzzon {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "生成"
            onClicked: {
                var fu = fuHan[ron ? 1 : 0][fuHanIndex][0];
                if (fu === 110 && selfWind !== roundWind) {
                    text.text = "110符时场风与自风必须一致";
                } else {
                    text.text = "少女做牌中";
                    // delay one frame to force the text flushed
                    timer.start()
                }
            }
        }
    }

    Timer {
        id: timer
        interval: 17
        onTriggered: {
            var fu = fuHan[ron ? 1 : 0][fuHanIndex][0];
            var han = fuHan[ron ? 1 : 0][fuHanIndex][1];
            pGen.genFuHan(fu, han, selfWind, roundWind, ron);
        }
    }
}



