import QtQuick 2.7
import "../js/girlnames.js" as Names
import "../widget"

Rectangle {
    property var foodChanges: []

    visible: false
    color: global.color.back

    Texd {
        visible: !foodChanges || foodChanges.length == 0
        anchors.centerIn: parent
        text: "正在搞事情……"
    }

    Column {
        visible: !!foodChanges && foodChanges.length > 0
        anchors.centerIn: parent
        spacing: global.size.gap

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: global.size.gap

            Column {
                Repeater {
                    model: foodChanges
                    delegate: Texd {
                        anchors.left: parent.left
                        font.pixelSize: global.size.middleFont
                        text: Names.replaceIdByName(modelData.Reason)
                    }
                }
            }

            Column {
                Repeater {
                    model: foodChanges
                    delegate: Texd {
                        anchors.right: parent.right
                        font.pixelSize: global.size.middleFont
                        text: modelData.Delta + "零食"
                    }
                }
            }
        }

        Buzzon {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "emmmm..."
            textLength: 6
            onClicked: {
                room.closed();
            }
        }
    }
}
