import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/girlnames.js" as Names
import "../widget"

Item {
    id: frame

    property int currGirlId: 0
    property var girlIds: []

    // height set by parent
    width: global.size.middleFont * 7

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
                textLength: 7
                onClicked: { currGirlId = modelData; }
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
