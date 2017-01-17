import QtQuick 2.0
import "widget"

Rectangle {
    id: shocker
    color: "transparent"
    width: 600
    height: 150

    Item {
        id: shifter
        visible: false
        anchors.verticalCenter: shocker.verticalCenter
        Texd {
            id: text
            color: "#DDFFFFFF"
            anchors.centerIn: parent
            font.pixelSize: 80
        }
    }

    SequentialAnimation {
        id: animateShock

        PropertyAction {
            target: shifter;
            property: "visible";
            value: true
        }

        NumberAnimation {
            target: shifter
            property: "x"
            from: 0
            to: shocker.width
            duration: 800
            easing.type: Easing.OutInExpo
        }

        PropertyAction {
            target: shifter;
            property: "visible";
            value: false
        }
    }

    function shock(act) {
        var dict_old = {PON: "▼ ポン", CHII: "◀ チー", DAIMINKAN: "■ カン",
                ANKAN: "■ カン", KAKAN: "■ カン", RIICHI: "！ リーチ",
                RON: "♂ ロン", TSUMO: "♀ ツモ"};
        var dict = {PON: "▼", CHII: "◀", DAIMINKAN: "■",
                ANKAN: "■", KAKAN: "■", RIICHI: "！",
                RON: "♂", TSUMO: "♀"};
        if (dict[act]) {
            text.text = dict[act];
            animateShock.start();
        }
    }
}

