import QtQuick 2.7
import "../widget"
import "../area"
import "../js/girlnames.js" as Names

Room {
    Fligable {
        id: flick
        anchors.left: parent.left
        anchors.right: girlMenu.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0.05 * parent.width
        anchors.rightMargin: 0.005 * parent.width
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height
        blaText: Names.blabla[girlMenu.currGirlId]
    }

    Texd {
        anchors.top: flick.bottom
        anchors.right: flick.right
        anchors.topMargin: global.size.space
        anchors.rightMargin: global.size.space
        font.pixelSize: global.size.smallFont
        text: "带（*）的尚未实现"
    }

    GirlMenu {
        id: girlMenu
        height: flick.height
        anchors.right: parent.right
        anchors.rightMargin: 0.05 * parent.width
        anchors.verticalCenter: parent.verticalCenter
        girlIds: Names.helpIds
    }
}


