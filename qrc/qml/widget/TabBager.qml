import QtQuick 2.7
import rolevax.sakilogy 1.0

Column {
    id: frame

    property var model: []
    property int currIndex

    spacing: global.size.space

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: global.size.space

        Repeater {
            id: repSelect
            model: frame.model.length
            delegate: Buzzon {
                text: frame.model[index]
                onClicked: {
                    currIndex = index;
                }
            }
        }
    }

    Rectangle {
        id: selectBar
        x: currIndex < repSelect.count ? repSelect.itemAt(currIndex).x : 0
        width: currIndex < repSelect.count ? repSelect.itemAt(currIndex).width : 0
        height: 0.25 * global.size.middleFont
        radius: 0.5 * height
        color: PGlobal.themeText
        opacity: 0.5

        Behavior on x {
            PropertyAnimation {
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }
    }
}
