import QtQuick 2.7

Rectangle {
    property string tileSet: "std"
    property color backColor: "#DD9900"

    // width set by parent
    height: 0.7 * width
    border.color: "grey"
    border.width: 2
    color: "#D2D2CC"
    Rectangle {
        width: parent.width - 4
        height: 0.25 * parent.height
        x: 2; y: 2
        color: backColor
    }
}
