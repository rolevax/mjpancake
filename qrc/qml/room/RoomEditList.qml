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
        anchors.right: photo.left
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
        model: PEditor.ls()

        delegate: Item {
            width: parent.width
            height: itemText.height

            Rectangle {
                visible: _currIndex === index
                anchors.fill: parent
                color: "blue"
            }

            Texd {
                id: itemText
                anchors.left: parent.left
                anchors.leftMargin: global.size.space
                text: modelData
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    _currIndex = index;
                }
            }
        }
    }

    GirlPhoto {
        id: photo
        anchors.bottom: listBackground.bottom
        anchors.right: parent.right
        anchors.rightMargin: 0.1 * parent.width
        width: 0.6 * height
        height: 0.6 * listBackground.height
        girlKey: { "id": (_currIndex >= 0 ? 1 : -1), "path": "" }
    }

    Column {
        anchors.right: photo.right
        anchors.top: listBackground.top
        spacing: global.size.space

        Buzzon {
            text: "新建人物"
            width: photo.width
            onClicked: {
                global.pushScene("room/RoomEditor");
            }
        }

        Buzzon {
            text: "编辑人物"
            width: photo.width
            enabled: _currIndex >= 0
            onClicked: {
                var cb = function(item) {
                    // FUCK
                };

                global.pushScene("room/RoomEditor", cb);
            }
        }

        Buzzon {
            text: "长按删除"
            width: photo.width
            enabled: _currIndex >= 0
            onLongClicked: {
                //
                _currIndex = -1;
            }
        }
    }
}
