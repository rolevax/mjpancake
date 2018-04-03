import QtQuick 2.7
import QtQuick.Dialogs 1.2
import rolevax.sakilogy 1.0

Item {
    signal imageAccepted(string path, url fileUrl)

    PImageSettings {
        id: pImageSettings

        onImagePathReceived: {
            imageAccepted(path);
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
            imageAccepted(filename, fileUrl);
        }
    }

    function open() {
        if (global.mobile)
            pImageSettings.getImagePathByAndroidGallery()();
        else
            fileDialog.open();
    }
}

