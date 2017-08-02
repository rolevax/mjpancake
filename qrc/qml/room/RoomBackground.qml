import QtQuick 2.7
import QtQuick.Dialogs 1.2
import rolevax.sakilogy 1.0
import "../widget"
import "../game"

Room {
    id: room

    showReturnButton: false

    PImageSettings {
        id: pImageSettings

        onBackgroundCopied: {
            global.reloadBackground();
        }
    }

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
                if (global.mobile)
                    pImageSettings.setBackgroundByAndroidGallery();
                else
                    fileDialog.open();
            }
        }

        Buzzon {
            text: "确定"
            smallFont: true
            onClicked: { room.closed(); }
        }
    }

    FileDialog {
        id: fileDialog
        title: "选图片啦"
        folder: shortcuts.pictures
        nameFilters: [ "图片文件 (*.jpg *.jpeg *.png *.gif *.bmp)" ]
        onAccepted: {
            // slice() to get rid of "file://" prefix
            // in Windoge's case, slice one more character
            // to get rid of the initial '/' and make it "C:/..."
            var filename = fileUrl.toString().slice(global.windows ? 8 : 7);
            pImageSettings.setBackground(filename);
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

    Component.onCompleted: {
        game.startSample();
    }
}
