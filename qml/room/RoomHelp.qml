import QtQuick 2.0
import rolevax.sakilogy 1.0
import "../widget"

Room {
    property var _loadTars: [ "Faq", "Op", "Rules", "Girls" ]
    property var _names: [ "常见问题", "操作说明", "麻将规则", "角色能力" ]

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Repeater {
            model: 4
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
