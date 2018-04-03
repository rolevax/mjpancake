import QtQuick 2.7
import QtQuick.Dialogs 1.2
import rolevax.sakilogy 1.0
import "../widget"
import "../game"

Room {
    id: room

    showReturnButton: false

    Game {
        id: game
    }

    Row {
        spacing: global.size.space
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.8

        GomboToggle {
            model: [ "牌副A", "牌副B" ]
            onActivated: { game.table.colorIndex = index; }
        }

        Buzzon {
            text: "背色"
            smallFont: true
            onClicked: { colorDialog.open(); }
        }

        Buzzon {
            text: "选图"
            smallFont: true
            onClicked: {
                imageBicker.open();
            }
        }

        Buzzon {
            text: "确定"
            smallFont: true
            onClicked: { room.closed(); }
        }
    }

    ImageBicker {
        id: imageBicker

        onImageAccepted: {
            PGlobal.setBackground(fileUrl);
        }
    }

    ColorDialog {
        id: colorDialog
        title: "选颜色啦"
        color: "#FFFFFF" // must give a value, otherwise it won't work
        onColorChanged: {
            var table = game.table;
            if (table && table.backColors) {
                table.backColors[table.colorIndex] = color;
                PGlobal.backColors = table.backColors;
            }
        }
    }

    Connections {
        target: PGlobal

        onBackgroundCopied: {
            global.reloadBackground();
        }
    }

    Component.onCompleted: {
        game.startSample();
    }
}
