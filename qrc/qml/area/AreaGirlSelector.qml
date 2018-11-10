import QtQuick 2.7
import "../widget"
import "../game"
import rolevax.sakilogy 1.0
import "../js/girlnames.js" as Names

Rectangle {
    id: frame

    signal selected

    property var girlKey: { "id": -1 }

    color: global.color.back

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // click blocker
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: selectMenu.left
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
            girlKey: frame.girlKey
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

    ChegList {
        id: checkList
        anchors.top: selectMenu.top
        anchors.right: selectMenu.left
        anchors.rightMargin: global.size.gap
        model: [ "天麻", "原创", "下载" ]
    }

    Item {
        id: selectMenu
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height
        anchors.rightMargin: 0.1 * parent.width
        width: sample.width + 2 * global.size.space

        LisdView {
            id: girlMenu
            visible: checkList.currIndex === 0
            anchors.fill: parent
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
                                frame.girlKey = { "id": modelData, "path": "" };
                            }
                        }
                    }
                }
            }
        }

        LisdView {
            id: customMenu
            visible: checkList.currIndex === 1
            anchors.fill: parent
            spacing: 2 * global.size.space
            model: PEditor.ls()
            delegate: Buzzon {
                width: parent.width
                text: modelData
                onClicked: {
                    frame.girlKey = { "id": 1, "path": modelData };
                }
            }
        }

        LisdView {
            id: downloadMenu
            visible: checkList.currIndex === 2
            anchors.fill: parent
            spacing: 2 * global.size.space
            model: PEditor.listCachedGirls()
            delegate: Column {
                width: parent.width
                spacing: global.size.space

                property var repoInfo: modelData

                Texd {
                    text: !!repoInfo.name ? repoInfo.name : repoInfo.repo
                }

                Repeater {
                    model: repoInfo.girls
                    delegate: Buzzon {
                        width: parent.width
                        text: modelData
                        onClicked: {
                            frame.girlKey = {
                                "id": 1,
                                "path": repoInfo.girlPathPrefix + "/" + modelData
                            };
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
