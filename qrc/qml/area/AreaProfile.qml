import QtQuick 2.7
import "../widget"
import "../game"

Item {
    id: frame

    property int girlId

    signal statClicked
    signal enterClicked

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
}
