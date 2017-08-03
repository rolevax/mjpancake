import QtQuick 2.7
import rolevax.sakilogy 1.0

Column {
    id: frame

    property var model: []
    property int currIndex: 0

    spacing: global.size.space

    Repeater {
        model: frame.model.length
        delegate: Item{
            width: row.width
            height: row.height

            Rectangle {
                anchors.fill: parent
                color: global.color.text
                opacity: 0.2
                visible: global.mobile ? mouseArea.containsPress : mouseArea.containsMouse
            }

            Row {
                id: row
                spacing: 2 * global.size.space

                Rectangle {
                    width: global.size.middleFont
                    height: width
                    radius: 0.5 * width
                    border.color: global.color.text
                    border.width: 0.1 * width
                    color: "transparent"

                    Rectangle {
                        width: 0.6 * parent.width
                        height: width
                        radius: 0.5 * width
                        anchors.centerIn: parent
                        color: global.color.text
                        visible: currIndex === index
                    }
                }

                Texd {
                    font.pixelSize: global.size.middleFont
                    text: frame.model[index]
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    currIndex = index;
                    global.sound.select.play();
                }
            }
        }
    }
}
