import QtQuick 2.7

Text {
    FontLoader { id: wqy; source: "/font/wqy-microhei.ttf" }
    font.family: wqy.name
    font.pixelSize: global.size.defaultFont
    color: global.color.text
}

