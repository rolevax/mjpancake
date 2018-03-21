import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/girlnames.js" as Names
import "../widget"

Item {
    id: frame

    property int initDealer
    property var points: [0, 0, 0, 0]
    property int tw
    readonly property var ys: [
        height / 300 * 75,
        height / 300 * 130,
        height / 300 * 185,
        height / 300 * 240
    ]

    width: height / 3 * 2
    height: 10 * tw

    Item {
        id: title
        x: tw / 6
        y: tw / 6
        width: frame.width - tw / 3
        height: frame.height / 300 * 70
        Texd {
            anchors.centerIn: parent
            text: "无胖次节操大会"
            font.pixelSize: tw / 3 * 2
            color: "white"
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 3
                color: "white"
                transform: Rotation {
                    origin.x: width / 4
                    origin.y: 1
                    angle: -5
                }
            }
        }
    }

    PointItem {
        id: item0
        name: "YOU"
        mark: "▼"
        width: frame.width
        internalMargin: tw / 3
        y: ys[0]
    }

    PointItem {
        id: item1
        name: "下家的逗比"
        mark: "▶"
        width: frame.width
        internalMargin: tw / 3
        y: ys[0]
    }

    PointItem {
        id: item2
        name: "对家的二比"
        mark: "▲"
        width: frame.width
        internalMargin: tw / 3
        y: ys[0]
    }

    PointItem {
        id: item3
        name: "上家的菜比"
        mark: "◀"
        width: frame.width
        internalMargin: tw / 3
        y: ys[0]
    }

    function setGirlKeys(girlKeys) {
        item0.name = Names.getName(girlKeys[0], PEditor);
        item1.name = Names.getName(girlKeys[1], PEditor);
        item2.name = Names.getName(girlKeys[2], PEditor);
        item3.name = Names.getName(girlKeys[3], PEditor);
    }

    onPointsChanged: {
        item0.point = points[0];
        item1.point = points[1];
        item2.point = points[2];
        item3.point = points[3];

        _resort();
    }

    onInitDealerChanged: {
        _resort();
    }

    function _resort() {
        function comp(i1, i2) {
            var diff = points[i2] - points[i1];
            if (diff !== 0)
                return diff;
            return (4 + i1 - initDealer) % 4 - (4 + i2 - initDealer) % 4
        }

        var items = [0, 1, 2, 3].sort(comp);
        item0.y = ys[items.indexOf(0)];
        item1.y = ys[items.indexOf(1)];
        item2.y = ys[items.indexOf(2)];
        item3.y = ys[items.indexOf(3)];
    }
}

