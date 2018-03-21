import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../area"
import "../widget"
import "../game"
import "../js/girlnames.js" as Names

Room {
    id: room

    property var girlKeys: [
        { "id": 0, "path": "" },
        { "id": 0, "path": "" },
        { "id": 0, "path": "" },
        { "id": 0, "path": "" }
    ]

    property var shuffledGirlKeys: [ null, null, null, null]
    property int tempDealer
    property bool shuffleSeat: false
    property bool _playing: false
    property int _selectingIndex: 0

    showReturnButton: !_playing

    Column {
        visible: !_playing
        spacing: global.size.gap
        anchors.centerIn: parent

        Row {
            id: configBoxes
            spacing: global.size.gap
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                id: girlColumn
                spacing: global.size.space

                Repeater {
                    model: 4
                    delegate:  Row {
                        spacing: global.size.gap

                        Texd {
                            anchors.verticalCenter: parent.verticalCenter
                            text: [ "P1", "C1", "C2", "C3" ][index]
                        }

                        Buzzon {
                            smallFont: true
                            textLength: 7
                            text: Names.getName(girlKeys[index], PEditor)
                            onClicked: {
                                _selectingIndex = index;
                                girlSelector.girlKey = girlKeys[index];
                                girlSelector.visible = true;
                            }
                        }
                    }
                }
            }

            RuleConfig {
                id: ruleConfig
            }
        }

        Rectangle { width: parent.width; height: 1; color: "grey" }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: global.size.space

            GomboToggle {
                model: [ "随机选人" ]
                sound: global.sound.button
                onActivated: {
                    var indices = Names.genIndices();
                    var tmp = [ {}, {}, {}, {} ];
                    for (var i in tmp) {
                        tmp[i].id = Names.availIds[indices[i]];
                        tmp[i].path = "";
                    }

                    girlKeys = tmp; // force refresh
                }
            }

            GomboToggle {
                model: [ "固定座位", "随机座位" ]
                onActivated: {
                    room.shuffleSeat = index === 1;
                }
            }

            GomboToggle {
                id: toggleTileSet
                model: [ "普通牌", "纸制牌" ]
            }
        }

        Texd {
            id: hintText
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: global.size.middleFont
            color: "black"
            text: ""
        }
    }

    Buzzon {
        visible: !_playing
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: global.size.space
        textLength: 8
        text: "开始"
        onClicked: {
            if (hasDupId()) {
                hintText.text = "角色不能重复（男的除外）<br/>";
            } else {
                hintText.text = "";
                PGlobal.save();
                _shuffleRivals();
                _playing = true;

                game.startLocal(shuffledGirlKeys, ruleConfig.gameRule, tempDealer);
            }
        }
    }

    AreaGirlSelector {
        id: girlSelector
        anchors.fill: parent
        visible: false
        onSelected: {
            var tmp = room.girlKeys;
            tmp[_selectingIndex] = girlSelector.girlKey;
            room.girlKeys = tmp; // force update signal
        }
    }

    Game {
        id: game
        visible: _playing
        focus: _playing
        table.tileSet: [ "std", "paper" ][toggleTileSet.currentIndex]
        table.onClosed: {
            room._playing = false;
        }
    }

    onClosed: {
        PGlobal.save();
    }

    function dupKey(key1, key2) {
        switch (key1.id) {
        case 0:
            return false; // doge
        case 1:
            return key2.id === 1 && key1.path === key2.path;
        default:
            return key1.id === key2.id;
        }
    }

    function hasDupId() {
        for (var i = 0; i < 4 - 1; i++)
            for (var j = i + 1; j < 4; j++)
                if (dupKey(girlKeys[i], girlKeys[j]))
                    return true;
        return false;
    }

    function _shuffleRivals() {
        // make a copy, avoid directly modifying 'girlKeys'
        // because 'girlKeys' should be consistant with combo boxes
        for (var i = 0; i < 4; i++)
            shuffledGirlKeys[i] = girlKeys[i];

        if (room.shuffleSeat) {
            var temp;
            // swap one of 1, 2, 3 into 1
            var p1 = 1 + Math.floor(Math.random() * 3);
            temp = shuffledGirlKeys[1];
            shuffledGirlKeys[1] = shuffledGirlKeys[p1];
            shuffledGirlKeys[p1] = temp;
            // swap one of 2, 3 into 2
            var p2 = 2 + Math.floor(Math.random() * 2);
            temp = shuffledGirlKeys[2];
            shuffledGirlKeys[2] = shuffledGirlKeys[p2];
            shuffledGirlKeys[p2] = temp;
            tempDealer = Math.floor(Math.random() * 4);
        } else {
            tempDealer = 0;
        }
    }
}


