import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../game"

Room {
    id: room

    property var girlKey: { "id": 1, "path": "" }
    property bool _usingExternalEditor: false

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
        color: "#BB000000"
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
                KeyNavigation.tab: inputName
            }

            TexdInput {
                id: inputName
                hintText: "人物名"
                text: girlKey.path ? PEditor.getName(girlKey.path) : ""
                textLength: 8
                KeyNavigation.tab: codeEdit
                KeyNavigation.backtab: inputPath
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
            visible: !_usingExternalEditor
            anchors.fill: codeBackground
            anchors.margins: global.size.space
            contentWidth: codeEdit.paintedWidth
            contentHeight: codeEdit.paintedHeight
            clip: true
            flickableDirection: Flickable.VerticalFlick

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
                height: flick.height
                selectByMouse: true
                wrapMode: TextEdit.Wrap
                onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                text: girlKey.path ? PEditor.getLuaCode(girlKey.path) : ""
                color: global.color.text
                font.pixelSize: global.size.defaultFont
                font.family: "Courier"

                Keys.onTabPressed: {
                    indentCurrLine();
                    event.accepted = true;
                }

                Keys.onBacktabPressed: {
                    backIndentCurrLine();
                    event.accepted = true;
                }

                property bool toDealEnter: false

                Keys.onReturnPressed: {
                    toDealEnter = true;
                    event.accepted = false;
                }

                Keys.onEnterPressed: {
                    toDealEnter = true;
                    event.accepted = false;
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_D) {
                        fixIndentAfterClose("en");
                    } else if (event.key === Qt.Key_E) {
                        fixIndentAfterClose("els");
                    } else if (event.key === Qt.Key_F) {
                        fixIndentAfterClose("elsei");
                    }

                    event.accepted = false;
                }

                onTextChanged: {
                    if (toDealEnter) {
                        toDealEnter = false;
                        indentAfterEnter();
                    }
                }

                function indentCurrLine() {
                    var lastEnter = getText(0, cursorPosition).lastIndexOf('\n');
                    insert(lastEnter + 1, "  ");
                }

                function backIndentCurrLine() {
                    var lastEnter = getText(0, cursorPosition).lastIndexOf('\n');

                    if (getText(lastEnter + 1, lastEnter + 3) === "  ")
                        remove(lastEnter + 1, lastEnter + 3);
                    else if (getText(lastEnter + 1, lastEnter + 2) === " ")
                        remove(lastEnter + 1, lastEnter + 2);
                }

                function indentAfterEnter() {
                    var cp = cursorPosition;
                    var lastEnter = getText(0, cp - 1).lastIndexOf('\n');
                    var prevLine = getText(lastEnter + 1, cp - 1);

                    var spaceCt = prevLine.search(/\S/);
                    if (isSurrounder(prevLine))
                        spaceCt += 2;

                    var lead = new Array(spaceCt + 1).join(" ");
                    insert(cp, lead);
                }

                function fixIndentAfterClose(tail) {
                    var lastEnter = getText(0, cursorPosition).lastIndexOf('\n');
                    var currLine = getText(lastEnter + 1, cursorPosition);
                    if (!(new RegExp("^\\s*" + tail + "$").test(currLine)))
                        return;

                    var prevEnter = text.substr(0, lastEnter).lastIndexOf('\n');
                    var prevLine = getText(prevEnter + 1, lastEnter);
                    var spaceCt = prevLine.search(/\S/);
                    if (!isSurrounder(prevLine))
                        spaceCt -= 2;

                    var lead = new Array(spaceCt + 1).join(" ") + tail;
                    remove(lastEnter + 1, cursorPosition);
                    insert(lastEnter + 1, lead);
                }

                function isSurrounder(line) {
                    if (/\bfunction\b.*\(.*\)\s*$/.test(line))
                        return true;

                    if (/\bthen\b\s*$/.test(line))
                        return true;

                    if (/\belse\b\s*$/.test(line))
                        return true;

                    if (/\belseif\b\s*$/.test(line))
                        return true;

                    if (/\bdo\b\s*$/.test(line))
                        return true;

                    return false;
                }
            }
        }

        Texd {
            text: "请使用外部工具编辑代码"
            visible: _usingExternalEditor
            anchors.centerIn: parent
        }

        Buzzon {
            text: "用外部工具打开"
            width: photo.width
            anchors.right: flick.right
            anchors.bottom: flick.bottom
            onClicked: {
                _usingExternalEditor = true;
                Qt.openUrlExternally(PEditor.getLuaCodeUrl(inputPath.text));
            }
        }

    }

    GirlPhoto {
        id: photo
        anchors.bottom: listBackground.bottom
        anchors.right: parent.right
        anchors.rightMargin: 0.1 * parent.width
        width: 0.6 * height
        height: (mouseArea.containsPress ? 0.95 : 1) * 0.6 * listBackground.height
        girlKey: room.girlKey

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                imagePicker.open();
            }
        }
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
            enabled: _pathOk()
            onClicked: {
                _save();
                room.closed();
            }
        }

        Buzzon {
            visible: !buttonSave.visible
            text: "改名并保存"
            width: photo.width
            enabled: _pathOk()
            onClicked: {
                _save();
                PEditor.remove(girlKey.path);
                room.closed();
            }
        }

        Buzzon {
            visible: !buttonSave.visible
            text: "以新名另存"
            width: photo.width
            enabled: _pathOk()
            onClicked: {
                _save();
                room.closed();
            }
        }

        Buzzon {
            text: "长按弃改"
            width: photo.width
            onLongClicked: {
                room.closed();
            }
        }
    }

    ImageBicker {
        id: imagePicker

        onImageAccepted: {
            photo.source = fileUrl;
        }
    }

    Component.onCompleted: {
        PEditor.setLuaHighlighter(codeEdit.textDocument)
    }

    function _pathOk() {
        return /^[a-zA-Z0-9_]+$/.test(inputPath.text);
    }

    function _save() {
        PEditor.saveJson(inputPath.text, inputName.text, photo.source);
        if (!_usingExternalEditor)
            PEditor.saveLuaCode(inputPath.text, codeEdit.text);
    }
}
