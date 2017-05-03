import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Room {
    property var _loadTars: [ "Faq", "Op", "Rules", "Rank", "Girls", "Adv" ]
    property var _names: [ "常见问题", "操作说明", "麻将规则", "段位规则", "角色能力", "制作人员" ]

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Repeater {
            model: _names.length
            delegate: Buzzon {
                text: _names[index]
                textLength: 8
                redDot: PGlobal.redDots[index]
                onClicked: {
                    loader.source = "RoomHelp" + _loadTars[index]  + ".qml";
                    var copy = PGlobal.redDots; // trigger signal
                    copy[index] = false;
                    PGlobal.redDots = copy;
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Item { width: 1; height: global.size.gap }

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            text: "本作之精华在于文档，麻将不过是个附赠品"
        }
    }

    function closeRoom() {
        loader.source = "";
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            item.closed.connect(closeRoom);
        }
    }

    onClosed: {
        PGlobal.save();
    }
}
