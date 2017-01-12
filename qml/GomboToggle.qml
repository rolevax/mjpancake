import QtQuick 2.0

Item {
    id: frame

    signal activated(int index)

    property var model: []
    property int currentIndex: 0
    property alias buddon: buddon
    property alias textLength: buddon.textLength

    width: buddon.width
    height: buddon.height

    Buzzon {
        id: buddon
        text: frame.model[frame.currentIndex]
        textLength: 5.5
        smallFont: true
        onClicked: {
            frame.currentIndex = (frame.currentIndex + 1) % frame.model.length;
            frame.activated(frame.currentIndex);
        }
    }

    onModelChanged: {
        frame.currentIndex = 0;
    }
}

