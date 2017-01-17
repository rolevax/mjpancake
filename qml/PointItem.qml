import QtQuick 2.0
import "widget"

Item {
    id: frame

    property int internalMargin
    property string name: "NoName"
    property string mark
    property int point: -1

    width: 200
    height: width / 200 * 60

    Item {
        anchors.centerIn: parent
        width: frame.width - internalMargin
        height: frame.height - internalMargin
        Column {
            anchors.left: parent.left
            anchors.leftMargin: 4
            Texd {
                id: nameText
                text: name
                font.pixelSize: frame.height / 60 * 17
                color: "white"
            }
            Texd {
                id: pointText
                text: point
                font.pixelSize: frame.height / 60 * 26
                color: "white"
            }
        }

        Texd {
            id: markText
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 5
            text:mark
            color: "#AAAAAA"
            font.pixelSize: frame.height / 3 * 2
        }
    }

    Behavior on point {
        SequentialAnimation {
            PauseAnimation { duration: 1000 }
            PropertyAnimation { duration: 1000 }
        }
    }

    Behavior on y {
        SequentialAnimation {
            PauseAnimation { duration: 2000 }
            PropertyAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }
    }
}

