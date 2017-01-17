import QtQuick 2.0
import "widget"

Rectangle {
    id: frame

    signal closed

    property var names: ["", "", "", ""]
    property var points: [0, 0, 0, 0]

    width: 0.75 * height
    height: 400
    z: 16
    anchors.centerIn: parent
    color: "#AA000000"
    visible: true
    Column {
        spacing: global.size.gap
        width: 0.75 * parent.width
        anchors.centerIn: parent

        Texd {
            color: "white"
            font.pixelSize: global.size.middleFont
            anchors.horizontalCenter: parent.horizontalCenter
            text: "終局"
        }

        Repeater {
            model: 4
            delegate: Item {
                width: parent.width
                height: 1.2 * global.size.middleFont
                Texd {
                    color: "white"
                    anchors.left: parent.left
                    font.pixelSize: global.size.middleFont
                    text: (index + 1) + "  " + frame.names[index]
                }

                Texd {
                    color: "white"
                    anchors.right: parent.right
                    font.pixelSize: global.size.middleFont
                    text: frame.shortNum(frame.points[index])
                }
            }
        }

        Buddon {
            text: "咕"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: { frame.closed(); }
        }
    }

    function shortNum(num) {
        var str = num === 0 ? "±" : num > 0 ? "+" : "";
        str += num;
        return str;
    }
}
