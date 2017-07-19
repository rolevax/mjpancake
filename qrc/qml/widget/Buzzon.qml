import QtQuick 2.7

Buddon {
    property bool redDot: false

    textColor: global.color.text
    lightColor: "#44777777"
    border.color: global.color.text
    color: global.color.back
    radius: global.size.space

    Rectangle {
        visible: redDot
        width: 0.4 * global.size.middleFont
        height: width
        radius: 0.5 * width
        color: "red"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: width
    }
}
