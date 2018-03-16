import QtQuick 2.7
import "../widget"
import "../game"
import "../js/girlnames.js" as Names

Rectangle {
    id: frame

    signal selected

    property alias girlId: photo.girlId

    color: global.color.back

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // click blocker
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
            height: 0.7 * parent.height
            cache: false
            girlId: 0
        }

        Buzzon {
            anchors.horizontalCenter: photo.horizontalCenter
            anchors.top: photo.bottom
            anchors.topMargin: global.size.gap
            text: "确定"
            textLength: 8
            onClicked: {
                frame.visible = false;
                selected();
            }
        }
    }

    LisdView {
        id: girlMenu
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height
        anchors.rightMargin: 0.1 * parent.width
        width: sample.width + 2 * global.size.space
        spacing: 2 * global.size.space
        model: Names.availSchools
        delegate: Column {
            spacing: global.size.space

            property string schoolId: modelData

            Texd {
                text: Names.schoolData[schoolId].name
            }

            Grid {
                spacing: global.size.space
                columns: 5
                Repeater {
                    model: Names.schoolData[schoolId].members
                    delegate: Buzzon {
                        textLength: 2
                        text: "" + modelData % 10
                        onClicked: {
                            photo.girlId = modelData;
                        }
                    }
                }
            }
        }
    }

    Grid {
        id: sample
        opacity: 0
        spacing: global.size.space
        columns: 5
        Repeater {
            model: 5
            delegate: Buzzon {
                textLength: 2
                text: "1"
            }
        }
    }
}
