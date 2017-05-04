import QtQuick 2.7
import rolevax.sakilogy 1.0
import QtQuick.Dialogs 1.2
import "../js/girlnames.js" as Names
import "../widget"
import "../area"
import "../game"

Room {
    id: frame

    PImageSettings {
        id: pImageSettings

        onPhotoCopied: {
            // force reload
            var temp = girlMenu.currGirlId;
            girlMenu.currGirlId = -1;
            girlMenu.currGirlId = temp;
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

        Row {
            id: row
            anchors.centerIn: parent
            spacing: global.size.gap

            GirlPhoto {
                id: photo
                width: 0.6 * height
                height: 0.5 * frame.height
                girlId: girlMenu.currGirlId
                cache: false
            }

            ChegList {
                id: checkList
                model: [ "自定义", "默认" ]
                onCurrIndexChanged: {
                    PGlobal.setPhoto(girlMenu.currGirlId, checkList.currIndex)
                }
            }

            Buzzon {
                text: "选图"
                enabled: checkList.currIndex === 0
                onClicked: {
                    if (global.mobile) {
                        pImageSettings.setPhotoByAndroidGallery(girlMenu.currGirlId);
                    } else {
                        fileDialog.open()
                    }
                }
            }
        }
    }

    GirlMenu {
        id: girlMenu
        height: 0.8 * frame.height
        anchors.right: parent.right
        anchors.rightMargin: 0.05 * parent.width
        anchors.verticalCenter: parent.verticalCenter
        girlIds: Names.allIds
        onCurrGirlIdChanged: {
            var value = PGlobal.photoMap[girlMenu.currGirlId];
            checkList.currIndex = value ? value : 0;
        }
        Component.onCompleted: { currGirlIdChanged(); }
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
}


