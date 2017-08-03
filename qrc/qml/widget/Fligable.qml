import QtQuick 2.7
import rolevax.sakilogy 1.0

Item {
    property string blaText

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.rightMargin: global.size.gap
        contentWidth: width
        contentHeight: text.height
        clip: true

        Texd {
            id: text
            lineHeight: 1.25
            width: parent.width
            wrapMode: Text.WrapAnywhere
            horizontalAlignment: Text.AlignLeft
            text: blaText
        }
    }

    Rectangle {
        id: barBack
        visible: flick.contentHeight > flick.height
        width: global.size.space
        height: parent.height
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: global.color.text
        opacity: 0.4
    }

    Rectangle {
        visible: barBack.visible
        width: barBack.width
        anchors.horizontalCenter: barBack.horizontalCenter
        height: (flick.height / flick.contentHeight) * barBack.height
        color: global.color.text
        opacity: 0.8
        y: flick.contentY / (flick.contentHeight - flick.height) * (barBack.height - height)
    }
}


