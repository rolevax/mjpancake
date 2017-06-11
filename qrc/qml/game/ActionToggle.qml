import QtQuick 2.7
import "../widget"

Rectangle {
    property bool checked: false
    property bool _light: global.mobile ? mouseArea.containsPress : mouseArea.containsMouse

    width: 2.67 * height
    height: global.size.middleFont
    color: _light ? "#FFFF00" : "#99FFFF00"

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        onClicked: { checked = !checked; }
    }

    Rectangle {
        id: checkBox
        width: 0.65 * parent.height
        height: width
        color: "#00000000"
        border.width: 2
        border.color: "black"
        anchors.left: parent.left
        anchors.leftMargin: 0.1 * parent.width
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            width: 0.5 * parent.width
            height: width
            color: "black"
            anchors.centerIn: parent
            visible: checked
        }
    }

    Texd {
        id: text
        anchors.left: checkBox.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 0.1 * parent.height
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: parent.height
        text: "!"
        color: "black"
    }
}

