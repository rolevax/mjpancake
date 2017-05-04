import QtQuick 2.7
import rolevax.sakilogy 1.0

Text {
    FontLoader { id: wqy; source: "/font/wqy-microhei.ttf" }
    font.family: wqy.name
    font.pixelSize: global.size.defaultFont
    color: PGlobal.themeText
}

