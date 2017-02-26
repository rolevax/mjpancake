import QtQuick 2.0
import QtQuick.Dialogs 1.2
import rolevax.sakilogy 1.0
import "../widget"

Room {
    id: room

    PImageSettings {
        id: pImageSettings

        onBackgroundCopied: {
            // force reload
            loader.source = "";
            loader.source = "../game/Game.qml";
            loader.item.startSample();
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        Buzzon {
            text: "更改牌桌背景"
            textLength: 8
            onClicked: {
                loader.source = "../game/Game.qml";
                loader.item.startSample();
            }
        }

        Buzzon {
            text: PGlobal.nightMode ? "开灯" : "关灯"
            textLength: 8
            onClicked: {
                PGlobal.nightMode = !PGlobal.nightMode;
            }
        }

        Buzzon {
            text: PGlobal.savePassword ? "保存密码 O" : "保存密码 X"
            textLength: 8
            onClicked: {
                PGlobal.savePassword = !PGlobal.savePassword;
            }
        }

        Buzzon {
            text: PGlobal.mute ? "音效 X" : "音效 O"
            textLength: 8
            onClicked: {
                PGlobal.mute = !PGlobal.mute;
            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    Row {
        id: backgroundButtons
        spacing: global.size.space
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.8
        visible: loader.source == Qt.resolvedUrl("../game/Game.qml")

        GomboToggle {
            model: [ "牌副A", "牌副B" ]
            onActivated: { loader.item.table.colorIndex = index; }
        }

        Buzzon {
            text: "背色"
            smallFont: true
            onClicked: {
                colorDialog.open();
            }
        }

        Buzzon {
            text: "选图"
            smallFont: true
            onClicked: {
                if (global.mobile) {
                    pImageSettings.setBackgroundByAndroidGallery();
                } else {
                    fileDialog.open()
                }
            }
        }

        Buzzon {
            text: "确定";
            smallFont: true
            onClicked: { loader.source = ""; }
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
            var table = loader.item.table;
            if (table && table.backColors) {
                table.backColors[table.colorIndex] = color;
                PGlobal.backColors = table.backColors;
            }
        }
    }

    function cancelHandler() { // override
        if (loader.source.toString() === "") {
            closed();
        } else {
            loader.source = "";
        }
    }

    onClosed: {
        PGlobal.save();
    }
}
