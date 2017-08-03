import QtQuick 2.7
import QtQuick.Dialogs 1.2
import rolevax.sakilogy 1.0
import "../widget"
import "../game"

Item {
    id: frame

    property int girlId

    signal statClicked
    signal enterClicked

    PImageSettings {
        id: pImageSettings

        onPhotoCopied: {
            // force reload
            photo.girlId = -1;
            photo.girlId = Qt.binding(function() { return girlId; });
        }
    }

    GirlPhoto {
        id: photo
        anchors.verticalCenter: parent.verticalCenter
        width: 0.6 * height
        height: frame.height
        girlId: frame.girlId
        cache: false
    }

    Item {
        anchors.left: photo.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: buttons.top

        Texd {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            text: "N段 233/2333Pt\nR1500\n第xxx名"
            font.pixelSize: 2 * global.size.middleFont
            shade: true
            shadePaddings: global.size.gap
        }
    }

    Row {
        id: buttons
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: global.size.space

        Buxxon {
            image: "/pic/icon/book.png"
            text: "排行"
            textLength: 6
            onClicked: {
            }
        }

        Buxxon {
            image: "/pic/icon/book.png"
            text: "统计"
            textLength: 6
            onClicked: {
                statClicked();
            }
        }

        Buxxon {
            image: "/pic/icon/book.png"
            text: "换肤"
            textLength: 6
            onClicked: {
                if (global.mobile) {
                    pImageSettings.setPhotoByAndroidGallery(girlMenu.currGirlId);
                } else {
                    fileDialog.open()
                }
            }
        }

        Buxxon {
            image: "/pic/icon/book.png"
            text: "入场"
            textLength: 6
            onClicked: {
                enterClicked();
            }
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
            pImageSettings.setPhoto(girlMenu.currGirlId, filename);
        }
    }
}
