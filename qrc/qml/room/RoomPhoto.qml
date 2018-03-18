import QtQuick 2.7
import QtQuick.Dialogs 1.2
import rolevax.sakilogy 1.0
import "../js/nettrans.js" as NetTrans
import "../js/girlnames.js" as Names
import "../widget"
import "../area"
import "../game"

Room {
    id: room

    PImageSettings {
        id: pImageSettings

        onPhotoCopied: {
            // force reload
            photo.girlKey = null;
            photo.girlKey = Qt.binding(function() { return { id: girlMenu.currGirlId }; });
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: girlMenu.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0.05 * parent.width
        anchors.rightMargin: 0.005 * parent.width
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height

        GirlPhoto {
            id: photo
            anchors.verticalCenter: parent.verticalCenter
            anchors.centerIn: parent
            width: 0.6 * height
            height: (mouseArea.containsPress ? 0.95 : 1) * 0.7 * parent.height
            girlKey: { "id": girlMenu.currGirlId, "path": "" }
            cache: false

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: { _pickPicture(); }
            }
        }
    }

    GirlMenu {
        id: girlMenu
        height: 0.8 * room.height
        anchors.right: parent.right
        anchors.rightMargin: 0.05 * parent.width
        anchors.verticalCenter: parent.verticalCenter
        girlIds: Names.allIds
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
            pImageSettings.setPhoto(girlMenu.currGirlId, filename);
        }
    }

    function _pickPicture() {
        if (global.mobile) {
            pImageSettings.setPhotoByAndroidGallery(girlMenu.currGirlId);
        } else {
            fileDialog.open()
        }
    }
}
