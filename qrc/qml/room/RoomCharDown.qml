import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../game"

Room {
    id: room

    property int _currIndex: -1

    Rectangle {
        id: listBackground
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: buttonColumn.left
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height
        anchors.leftMargin: 0.1 * parent.width
        anchors.rightMargin: global.size.gap
        color: global.color.back
    }

    LisdView {
        id: entryList

        anchors.fill: listBackground
        spacing: global.size.space
        width: 0.4 * room.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        model: []

        delegate: Item {
            width: parent.width
            height: itemColumn.height

            Rectangle {
                visible: _currIndex === index
                anchors.fill: parent
                color: "#000044"
            }

            Column {
                id: itemColumn
                Texd {
                    anchors.left: parent.left
                    anchors.leftMargin: global.size.space
                    text: modelData.name
                }
                Texd {
                    anchors.left: parent.left
                    anchors.leftMargin: global.size.space
                    text: "- UP主：" + modelData.uploader
                }
                Texd {
                    anchors.left: parent.left
                    anchors.leftMargin: global.size.space
                    text: "- GitHub地址：" + modelData.repo
                }
                Texd {
                    anchors.left: parent.left
                    anchors.leftMargin: global.size.space
                    text: "- 简介：" + modelData.desc
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    _currIndex = index;
                }
            }
        }
    }

    Column {
        id: buttonColumn

        anchors.right: parent.right
        anchors.rightMargin: 0.1 * parent.width
        anchors.top: listBackground.top
        width: 0.36 * listBackground.height

        spacing: global.size.space

        Buzzon {
            text: "同步人物包"
            width: parent.width
            enabled: _currIndex >= 0
            onClicked: {
            }
        }

        Buzzon {
            text: "删除人物包"
            width: parent.width
            enabled: _currIndex >= 0
            onLongClicked: {
            }
        }
    }

    Connections {
        target: PEditor

        onSignedReposReplied: {
            entryList.model = repos;
        }
    }

    Component.onCompleted: {
        PEditor.fetchSignedRepos();
    }
}
