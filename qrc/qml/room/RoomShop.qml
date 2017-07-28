import QtQuick 2.7
import "../widget"

Room {
    Buxxon {
        id: sample
        opacity: 0
        textLength: 8
        height: width + 2.5 * fontSize
        text: "haha\n$888.0"
    }

    LisdView {
        width: 0.8 * parent.width
        height: sample.height + shrink
        anchors.centerIn: parent
        spacing: global.size.space
        orientation: ListView.Horizontal
        model: 15
        delegate: Buxxon {
            textLength: 8
            height: width + 2.5 * fontSize
            text: "haha\n$888.0"
        }
    }
}
