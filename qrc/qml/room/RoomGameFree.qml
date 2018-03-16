import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../area"
import "../widget"
import "../game"
import "../js/girlnames.js" as Names

Room {
    id: room

    property var girlIds: [ 0, 0, 0, 0 ]
    property var shuffledGirlIds: [ 0, 0, 0, 0 ]
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
            z: 10

            Column {
                id: girlColumn
                spacing: global.size.space
                z: 2

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
                            enabled: index === 0 || toggleMode.currentIndex === 0
                            text: Names.names[girlIds[index]]
                            onClicked: {
                                _selectingIndex = index;
                                girlSelector.girlId = girlIds[index];
                                girlSelector.visible = true;
                            }
                        }
                    }
                }
            }

            RuleConfig {
                id: ruleConfig
                z: 1
            }
        }

        Rectangle { z: 9; width: parent.width; height: 1; color: "grey" }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: global.size.space
            z: 8

            GomboToggle {
                model: [ "随机选人" ]
                sound: global.sound.button
                onActivated: {
                    var indices = Names.genIndices();
                    var tmp = [ 0, 0, 0, 0 ];
                    for (var i in tmp)
                        tmp[i] = Names.availIds[indices[i]];
                    girlIds = tmp; // force refresh
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

            GomboToggle {
                id: toggleMode
                model: [ "一人三机", "摸打练习" ]
            }
        }

        Texd {
            id: hintText
            z: 7
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

                if (toggleMode.currentIndex === 0) {
                    game.startLocal(shuffledGirlIds, ruleConfig.gameRule, tempDealer);
                } else {
                    game.startPrac(shuffledGirlIds[0]);
                }
            }
        }
    }

    AreaGirlSelector {
        id: girlSelector
        anchors.fill: parent
        visible: false
        onSelected: {
            var tmp = room.girlIds;
            tmp[_selectingIndex] = girlSelector.girlId;
            room.girlIds = tmp; // force update signal
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

    function dupId(id1, id2) {
        return id1 !== 0 && id1 === id2;
    }

    function hasDupId() {
        for (var i = 0; i < 4 - 1; i++)
            for (var j = i + 1; j < 4; j++)
                if (dupId(girlIds[i], girlIds[j]))
                    return true;
        return false;
    }

    function _shuffleRivals() {
        // make a copy, avoid directly modifying 'girlIds'
        // because 'girlIds' should be consistant with combo boxes
        for (var i = 0; i < 4; i++)
            shuffledGirlIds[i] = girlIds[i];

        if (room.shuffleSeat) {
            var temp;
            // swap one of 1, 2, 3 into 1
            var p1 = 1 + Math.floor(Math.random() * 3);
            temp = shuffledGirlIds[1];
            shuffledGirlIds[1] = shuffledGirlIds[p1];
            shuffledGirlIds[p1] = temp;
            // swap one of 2, 3 into 2
            var p2 = 2 + Math.floor(Math.random() * 2);
            temp = shuffledGirlIds[2];
            shuffledGirlIds[2] = shuffledGirlIds[p2];
            shuffledGirlIds[p2] = temp;
            tempDealer = Math.floor(Math.random() * 4);
        } else {
            tempDealer = 0;
        }
    }
}


