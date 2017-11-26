import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Room {
    showReturnButton: false

    Row {
        anchors.centerIn: parent
        spacing: global.size.space

        Buxxon {
            text: "踩地板"
            textLength: 16
            enabled: PClient.loggedIn
            onClicked: {
                global.pushScene("room/RoomClient");
            }
        }

        Item {
            width: miscRow.width
            height: parent.height

            Row {
                id: miscRow
                anchors.top: parent.top
                spacing: global.size.space

                Repeater {
                    model: [
                        { text: "麻将部备品", load: "Tools" },
                        { text: "设置", load: "Settings" }
                    ]

                    delegate: Buxxon {
                        text: modelData.text
                        textLength: 8
                        onClicked: {
                            global.pushScene("room/Room" + modelData.load);
                        }
                    }
                }

                Buxxon {
                    text: "骑马"
                    textLength: 8
                    onClicked: { Qt.quit(); }
                }
            }

            Buxxon {
                width: parent.width
                anchors.top: miscRow.bottom
                anchors.topMargin: global.size.space
                anchors.bottom: parent.bottom
                text: "松饼社区主站"
                onClicked: {
                    Qt.openUrlExternally("https://mjpancake.github.io/");
                }
            }
        }
    }
}
