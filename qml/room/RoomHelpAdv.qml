import QtQuick 2.7
import "../widget"

Room {
    Fligable {
        anchors.fill: parent
        anchors.leftMargin: 0.05 * parent.width
        anchors.rightMargin: 0.05 * parent.width
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height
        blaText: blabla
    }

    readonly property string blabla:
        "<h3>制作组成员</h3>" +
        "<ul>" +
        "<li>(todo)</li>" +
        "</ul>" +
        "<h3>大力协助</h3>" +
        "<ul>" +
        "<li>(todo)</li>" +
        "</ul>" +
        ""
}


