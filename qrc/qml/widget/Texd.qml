import QtQuick 2.7

Text {
    property bool shade: false
    property real shadePaddings: 0

    font.family: wqy.name
    font.pixelSize: global.size.defaultFont
    color: global.color.text

    Rectangle {
        visible: shade
        z: -1
        anchors.fill: parent
        anchors.margins: -shadePaddings
        color: global.color.back
    }

    FontLoader {
        id: wqy
        source: "/font/wqy-microhei.ttf"
    }
}

