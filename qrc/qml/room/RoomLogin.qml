import QtQuick 2.7
import "../widget"
import "http://118.89.219.207/ih.js" as Ih

Room {
    showReturnButton: false

    Rectangle {
        color: global.color.back
        anchors.fill: names
        anchors.margins: -global.size.gap
    }

    Column {
        id: names
        anchors.centerIn: parent
        spacing: global.size.space

        Repeater {
            model: Ih.staffs

            delegate: Column {
                anchors.horizontalCenter: parent.horizontalCenter

                Texd {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "[" + modelData.role + "]"
                    font.pixelSize: global.size.middleFont
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: global.size.space

                    Repeater {
                        model: modelData.names
                        Texd {
                            text: modelData
                            font.pixelSize: global.size.middleFont
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            global.pushScene("room/RoomMainMenu");
        }
    }
}
