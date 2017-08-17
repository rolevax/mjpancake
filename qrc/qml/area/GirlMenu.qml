import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/girlnames.js" as Names
import "../widget"

Item {
    id: frame

    readonly property int currGirlId: girlIds ? girlIds[currIndex] : -1
    property int currIndex: 0
    property var girlIds: null
    property real textLength: 7.5

    // height set by parent
    width: global.size.middleFont * textLength

    Texd {
        anchors.bottom: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: global.size.middleFont
        text: listView.atYBeginning ? "" : "▲"
    }

    ListView {
        id: listView
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1.1 * parent.width
        model: girlIds
        spacing: global.size.space
        clip: true
        delegate: Row {
            width: girlButton.width

            Item {
                width: 0.1 * frame.width
                height: 1
                visible: modelData === currGirlId
            }

            Buzzon {
                id: girlButton
                text: Names.names[modelData]
                textLength: frame.textLength
                onClicked: {
                    currIndex = index;
                    currGirlId = modelData;
                }
            }
        }
    }

    Texd {
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: global.size.middleFont
        text: listView.atYEnd ? "" : "▼"
    }
}
