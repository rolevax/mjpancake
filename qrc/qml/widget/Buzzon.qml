import QtQuick 2.7
import rolevax.sakilogy 1.0

Buddon {
    property bool redDot: false

    textColor: PGlobal.themeText
    lightColor: "#44777777"
    border.color: PGlobal.themeText
    color: PGlobal.themeBack
    radius: height / 3

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
