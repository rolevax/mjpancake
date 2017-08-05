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

                GirlBox {
                    id: girlBox0; mark: "P1"; z: 104
                    onChoosen: { girlIds[0] = girlId; }
                }
                GirlBox {
                    id: girlBox1; mark: "C1"; z: 103
                    onChoosen: { girlIds[1] = girlId; }
                }
                GirlBox {
                    id: girlBox2; mark: "C2"; z: 102
                    onChoosen: { girlIds[2] = girlId; }
                }
                GirlBox {
                    id: girlBox3; mark: "C3"; z: 101
                    onChoosen: { girlIds[3] = girlId; }
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
                    girlBox0.chooseByAvalIndex(indices[0]);
                    girlBox1.chooseByAvalIndex(indices[1]);
                    girlBox2.chooseByAvalIndex(indices[2]);
                    girlBox3.chooseByAvalIndex(indices[3]);
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
                game.startLocal(shuffledGirlIds, ruleConfig.gameRule, tempDealer);
            }
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


