import QtQuick 2.7
import QtQuick.Dialogs 1.2
import rolevax.sakilogy 1.0

Item {
    signal imageAccepted(url fileUrl)

    PImageSettings {
        id: pImageSettings

        onImageUrlReceived: {
            imageAccepted(fileUrl);
        }
    }

    FileDialog {
        id: fileDialog
        title: "选图片啦"
        folder: shortcuts.pictures
        nameFilters: [ "图片文件 (*.jpg *.jpeg *.png *.gif *.bmp)" ]
        onAccepted: {
            imageAccepted(fileUrl);
        }
    }

    function open() {
        if (global.mobile)
            pImageSettings.getImagePathByAndroidGallery();
        else
            fileDialog.open();
    }
}

