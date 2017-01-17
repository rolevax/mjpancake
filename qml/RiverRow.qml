import QtQuick 2.0
import "widget"

ListView {
    id: frame

    property bool animEnabled: true
    property string tileSet: "std"
    property color backColor
    property int tw

    property bool showCircle: false
    property bool flashCircle: false
    property point outCoord

    width: 6 * tw;
    height: 1.35 * tw
    orientation: Qt.Horizontal;
    interactive: false
    delegate: Item {
        width: tile.width
        height: tile.height

        Rectangle {
            id: blinkingCircle
            anchors.centerIn: parent
            width: 2 * tw
            height: 2 * tw
            color: "#00000000"
            border.color: "white"
            border.width: 2
            radius: width / 2
            visible: showCircle && flashCircle && index === frame.model.count - 1
            SequentialAnimation on opacity {
                PropertyAnimation { to: 0; duration: 500 }
                PropertyAnimation { to: 0.5; duration: 500 }
                loops: Animation.Infinite
                running: true
            }
        }

        Rectangle {
            id: solidCircle
            anchors.centerIn: parent
            width: 2 * tw
            height: 2 * tw
            color: "#00000000"
            border.color: "white"
            border.width: 2
            radius: width / 2
            visible: showCircle && !flashCircle && index === frame.model.count - 1
        }

        Tile {
            id: tile
            tileSet: frame.tileSet
            tileWidth: tw
            tileStr: modelTileStr
            backColor: frame.backColor
            lay: modelLay
        }
    }

    add: Transition {
        enabled: frame.animEnabled
        NumberAnimation {
            property: "y"
            from: outCoord.y
            duration: 200
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            property: "x"
            from: outCoord.x
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
}
