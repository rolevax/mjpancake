import QtQuick 2.7
import "../widget"

Grid {
    property var gameRule: {
        "roundLimit": 8,
        "fly": true, "returnLevel": 30000, "hill": 20000,
        "headJump": true, "daiminkanPao": true,
        "nagashimangan": true, "ippatsu": true,
        "uradora": true, "kandora": true,
        "akadora": 2 // int 2 denotes 4 akadoras
    }

    spacing: global.size.space
    flow: Grid.TopToBottom
    rows: 4

    GomboToggle {
        model: [ "东风", "东南" ]
        onActivated: { gameRule.roundLimit = (index + 1) * 4 }
        Component.onCompleted: { currentIndex = gameRule.roundLimit / 4 - 1; }
    }

    GomboToggle {
        model: ["击飞 X", "击飞 O"]
        onActivated: { gameRule.fly = index }
        Component.onCompleted: { currentIndex = gameRule.fly; }
    }

    GomboToggle {
        model: [ 30000, 100000 ]
        onActivated: { gameRule.returnLevel = model[index]; }
    }

    GomboToggle {
        model: [ "丘20", "丘0" ]
        onActivated: { gameRule.hill = [ 20000, 0 ][index]; }
    }

    GomboToggle {
        model: [ "2和/3流", "头跳" ]
        onActivated: { gameRule.headJump = index; }
        Component.onCompleted: { currentIndex = gameRule.headJump; }
    }

    GomboToggle {
        model: ["里宝牌 X", "里宝牌 O"]
        onActivated: { gameRule.uradora = index }
        Component.onCompleted: { currentIndex = gameRule.uradora; }
    }

    GomboToggle {
        model: ["杠宝牌 X", "杠宝牌 O"]
        onActivated: { gameRule.kandora = index }
        Component.onCompleted: { currentIndex = gameRule.kandora; }
    }

    GomboToggle {
        model: [ "赤0", "赤3", "赤4" ]
        onActivated: { gameRule.akadora = index }
        Component.onCompleted: { currentIndex = gameRule.akadora; }
    }

    GomboToggle {
        model: ["荒牌满贯 X", "荒牌满贯 O"]
        onActivated: { gameRule.nagashimangan = index }
        Component.onCompleted: { currentIndex = gameRule.nagashimangan; }
    }

    GomboToggle {
        model: ["一发 X", "一发 O"]
        onActivated: { gameRule.ippatsu = index }
        Component.onCompleted: { currentIndex = gameRule.ippatsu; }
    }

    GomboToggle {
        model: ["包杠 X", "包杠 O"]
        onActivated: { gameRule.daiminkanPao = index }
        Component.onCompleted: { currentIndex = gameRule.daiminkanPao; }
    }
}
