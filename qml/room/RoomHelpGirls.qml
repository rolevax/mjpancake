import QtQuick 2.0
import '../widget'
import "../js/girlnames.js" as Names

Room {
    property int currIndex: 0

    Flickable {
        id: flick
        height: 0.8 * parent.height
        contentWidth: width
        contentHeight: text.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 0.1 * parent.width
        anchors.right: girlList.left
        anchors.rightMargin: 0.02 * parent.width
        clip: true

        Texd {
            id: text
            lineHeight: 1.5
            width: parent.width
            wrapMode: Text.WrapAnywhere
            horizontalAlignment: Text.AlignLeft
            text: Names.blabla[Names.availIds[currIndex]]
        }
    }

    Texd {
        anchors.right: flick.right
        anchors.top: flick.bottom
        font.pixelSize: global.size.smallFont
        text: "带（*）的是尚未实现的\n页面和名单可以上下滚动"
    }

    ListView {
        id: girlList
        height: flick.height
        width: global.size.middleFont * 7
        anchors.right: parent.right
        anchors.rightMargin: 0.1 * parent.width
        anchors.verticalCenter: parent.verticalCenter
        model: Names.availIds.length
        spacing: global.size.space
        delegate: Row {
            anchors.right: parent.right
            width: girlButton.width

            Item {
                width: 0.1 * parent.width
                height: 1
                visible: index === currIndex
            }

            Buzzon {
                id: girlButton
                text: Names.names[Names.availIds[index]]
                textLength: 7
                onClicked: { currIndex = index; }
            }
        }
    }
}


