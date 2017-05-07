import QtQuick 2.7
import rolevax.sakilogy 1.0

Item {
    id: frame

    property var model
    property Component delegate
    property real spacing

    ListView {
        id: list
        width: frame.width - barBack.width - global.size.space
        anchors.left: frame.left
        anchors.top: frame.top
        anchors.bottom: frame.bottom
        clip: true

        model: frame.model
        delegate: frame.delegate
        spacing: frame.spacing
    }

    Rectangle {
        id: barBack
        visible: list.contentHeight > list.height
        width: global.size.space
        height: frame.height
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: PGlobal.themeText
        opacity: 0.4
    }

    Rectangle {
        visible: barBack.visible
        width: barBack.width
        anchors.horizontalCenter: barBack.horizontalCenter
        height: (list.height / list.contentHeight) * barBack.height
        color: PGlobal.themeText
        opacity: 0.8
        y: list.contentY / (list.contentHeight - list.height) * (barBack.height - height)
    }
}


