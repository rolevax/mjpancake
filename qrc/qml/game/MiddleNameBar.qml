import QtQuick 2.7
import "../widget"

Item {
    id: frame

    property bool animEnabled: true
    property bool showPointDiff: false
    property real tw
    property alias seatText: seatText
    property int point: 0
    property int myPoint: 0

    width: 4 * tw
    height: tw / 3 * 2

    Rectangle {
        id: seatBox
        property alias seatText: seatText
        width: frame.height
        height: frame.height
        anchors.left: parent.left
        color: "black"
        Texd {
            id: seatText
            color: "white"
            anchors.centerIn: parent
            font.pixelSize: parent.height - 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Texd {
        id: pointText
        visible: !showPointDiff
        width: frame.width - seatBox.width - frame.height / 4
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: frame.height - 1
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "black"
        text: point
    }

    Texd {
        id: diffText
        visible: showPointDiff
        width: pointText.width
        anchors.centerIn: pointText
        font.pixelSize: pointText.font.pixelSize
        horizontalAlignment: pointText.horizontalAlignment
        verticalAlignment: pointText.verticalAlignment
        color: pointText.color
        text: (myPoint - point > 0 ? "+" : "") + (myPoint - point)
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        width: barCol.width
        Column {
            id: barCol
            spacing: -8

            Repeater {
                model: ListModel { id: barModel }
                delegate: Image {
                    width: tw * 4 - 5
                    fillMode: Image.PreserveAspectFit
                    source: "/pic/bar/bar1000.png"
                }
            }

            add: Transition {
                enabled: animEnabled
                NumberAnimation {
                    property: "y"
                    from: tw * 3
                    duration: 200
                    easing.type: Easing.InQuad
                }
            }
        }
    }

    Behavior on point {
        PropertyAnimation { duration: 1000 }
    }

    function hasBar() {
        return barModel.count > 0;
    }

    function addBar() {
        barModel.append({});
    }

    function removeBars() {
        barModel.clear();
    }
}
