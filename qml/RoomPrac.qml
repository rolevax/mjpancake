import QtQuick 2.0
import QtQuick.Controls 1.2
import rolevax.sakilogy 1.0
import "widget"

Room {
    Texd {
        font.pixelSize: 18
        text: "。。。"
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            item.table.closed.connect(closeTable);
        }
    }
}
