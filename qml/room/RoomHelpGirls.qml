import QtQuick 2.0
import '../widget'
import "../js/girlnames.js" as Names

Room {
    property int currIndex: 0

    Fligable {
        id: flick
        anchors.left: parent.left
        anchors.right: girlList.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0.05 * parent.width
        anchors.rightMargin: 0.005 * parent.width
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height
        blaText: Names.blabla[Names.helpIds[currIndex]]
    }

    Texd {
        anchors.top: flick.bottom
        anchors.right: flick.right
        anchors.topMargin: global.size.space
        anchors.rightMargin: global.size.space
        font.pixelSize: global.size.smallFont
        text: "带（*）的是尚未实现的"
    }

    ListView {
        id: girlList
        height: flick.height
        width: global.size.middleFont * 7
        anchors.right: parent.right
        anchors.rightMargin: 0.05 * parent.width
        anchors.verticalCenter: parent.verticalCenter
        model: Names.helpIds.length
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
                text: Names.names[Names.helpIds[index]]
                textLength: 7
                onClicked: { currIndex = index; }
            }
        }
    }
}


