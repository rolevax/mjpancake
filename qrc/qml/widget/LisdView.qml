import QtQuick 2.7
import rolevax.sakilogy 1.0

Item {
    id: frame

    property var model
    property Component delegate
    property real spacing
    property alias orientation: list.orientation
    readonly property bool hori: orientation === ListView.Horizontal
    readonly property real shrink: (hori ? barBack.height : barBack.width) + global.size.space

    ListView {
        id: list
        width: frame.width - (hori ? 0 : shrink)
        height: frame.height - (hori ? shrink : 0)
        anchors.left: frame.left
        anchors.top: frame.top
        spacing: frame.spacing
        clip: true

        model: frame.model
        delegate: frame.delegate
    }

    Rectangle {
        id: barBack
        visible: hori ? list.contentWidth > list.width
                      : list.contentHeight > list.height
        width: hori ? frame.width : global.size.space
        height: hori ? global.size.space : frame.height
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: global.color.text
        opacity: 0.4
    }

    Rectangle {
        visible: barBack.visible
        width: hori ? (list.width / list.contentWidth) * barBack.width : barBack.width
        height: hori ? barBack.height : (list.height / list.contentHeight) * barBack.height
        x: hori ? list.contentX / (list.contentWidth - list.width) * (barBack.width - width)
                : barBack.x
        y: hori ? barBack.y
                : list.contentY / (list.contentHeight - list.height) * (barBack.height - height)
        color: global.color.text
        opacity: 0.8
    }

    MouseArea {
        anchors.fill: parent
        enabled: hori
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        onWheel: {
            var dy = wheel.angleDelta.y;
            if (dy !== 0) {
                wheel.accepted = true;
                if (dy < 0) { // scroll down
                    list.contentX += 0.1 * parent.width;
                    if (list.contentX > list.contentWidth - list.width)
                        list.contentX = list.contentWidth - list.width;
                } else if (dy > 0) { // scroll up
                    list.contentX -= 0.1 * parent.width;
                    if (list.contentX < 0)
                        list.contentX = 0;
                }
            }
        }
    }
}


