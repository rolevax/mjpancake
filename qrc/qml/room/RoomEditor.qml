import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../game"

Room {
    id: room

    property var girlKey: { "id": 1, "path": "" }

    showReturnButton: false

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

    Item {
        anchors.fill: listBackground

        Row {
            id: nameRow
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: global.size.space
            spacing: global.size.space

            TexdInput {
                id: inputPath
                hintText: "文件名"
                text: girlKey.path ? girlKey.path : ""
                textLength: 8
            }

            TexdInput {
                id: inputName
                hintText: "人物名"
                text: girlKey.path ? PEditor.getName(girlKey.path) : ""
                textLength: 8
            }
        }

        Rectangle {
            id: codeBackground

            anchors.top: nameRow.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: global.size.space

            color: "transparent"
            border.color: inputPath.border.color
            border.width: inputPath.border.width
        }

        Flickable {
            id: flick
            anchors.fill: codeBackground
            anchors.margins: global.size.space
            contentWidth: codeEdit.paintedWidth
            contentHeight: codeEdit.paintedHeight
            clip: true
            flickableDirection: Flickable.VerticalFlick
            // FUCK support mouse wheel

            function ensureVisible(r) {
                if (contentX >= r.x)
                    contentX = r.x;
                else if (contentX+width <= r.x + r.width)
                    contentX = r.x + r.width - width;
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY+height <= r.y + r.height)
                    contentY = r.y+r.height - height;
            }

            TextEdit {
                id: codeEdit
                width: flick.width
                focus: true
                wrapMode: TextEdit.Wrap
                onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                text: girlKey.path ? PEditor.getLuaCode(girlKey.path) : ""
                color: global.color.text
                font.pixelSize: global.size.defaultFont
                // FUCK find a monospace font
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
        girlKey: room.girlKey
    }

    Column {
        anchors.right: photo.right
        anchors.top: listBackground.top
        spacing: global.size.space

        Buzzon {
            id: buttonSave
            text: "保存"
            width: photo.width
            visible: !girlKey.path || girlKey.path === inputPath.text
            enabled: !!inputPath.text
            onClicked: {
                // FUCK validate filename
                var saveData = {
                    path: inputPath.text
                };

                PEditor.save(inputPath.text, inputName.text, codeEdit.text);
                room.closed();
            }
        }

        Buzzon {
            visible: !buttonSave.visible
            text: "改名并保存"
            width: photo.width
            // when filename !== old_filename
        }

        Buzzon {
            visible: !buttonSave.visible
            text: "以新名另存"
            width: photo.width
            // when filename !== old_filename
        }

        Buzzon {
            text: "长按弃改"
            width: photo.width
            onLongClicked: {
                room.closed();
            }
        }
    }
}
