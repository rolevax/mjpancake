import QtQuick 2.7

Item {
    id: frame

    signal activated(int index)

    property var model: []
    property int currentIndex: 0
    property alias buddon: buddon
    property alias textLength: buddon.textLength
    property alias enabled: buddon.enabled

    width: buddon.width
    height: buddon.height

    MouseArea {
        // cover the whole screen wherever the menu is
        width: global.window.width * 2
        height: global.window.height * 2
        x: -global.window.width
        y: -global.window.height
        visible: popUp.visible

        onClicked: {
            popUp.visible = false;
        }
    }

    Buzzon {
        id: buddon
        text: frame.model[frame.currentIndex]
        textLength: 5.5
        smallFont: true
        onClicked: {
            popUp.visible = !popUp.visible;
        }
    }

    Rectangle {
        id: popUp
        color: buddon.color
        border.width: buddon.border.width
        border.color: buddon.border.color
        height: grid.height + border.width * 4 // a little bigger than 2x
        width: grid.width + border.width * 4
        anchors.top: buddon.bottom
        anchors.left: buddon.left
        anchors.topMargin: border.width + 1
        visible: false

        Grid {
            id: grid
            anchors.centerIn: parent
            flow: Grid.TopToBottom
            rows: global.mobile ? 7 : 10

            Repeater {
                id: rep
                delegate:  GomboBuddon {
                    text: modelData
                    width: buddon.width - 2 * buddon.border.width
                    height: buddon.height - 2 * buddon.border.width
                    onClicked: {
                        popUp.visible = false;
                        frame.currentIndex = index;
                        frame.activated(index);
                    }
                }
                model: frame.model
            }
        }
    }

    onModelChanged: {
        frame.currentIndex = 0;
        activated(currentIndex);
    }
}
