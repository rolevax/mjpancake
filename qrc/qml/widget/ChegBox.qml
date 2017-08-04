import QtQuick 2.7

Item{
    id: frame

    property string text
    property bool checked: false

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
            border.color: global.color.text
            border.width: 0.1 * width
            color: "transparent"

            Rectangle {
                width: 0.6 * parent.width
                height: width
                anchors.centerIn: parent
                color: global.color.text
                visible: frame.checked
            }
        }

        Texd {
            font.pixelSize: global.size.middleFont
            text: frame.text
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            frame.checked = !frame.checked;
            global.sound.select.play();
        }
    }
}
