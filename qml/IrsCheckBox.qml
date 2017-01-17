import QtQuick 2.0
import "widget"
import "spell.js" as Spell

Rectangle {
    id: frame

    signal actionTriggered(int mask)

    property int fontSize

    color: "#AA000000"
    width: fontSize * 12
    height: column.height + 3 * fontSize
    visible: false

    ListModel { id: listModel }

    Component {
        id: listDelegate
        Rectangle {
            width: 0.7 * frame.width
            height: fontSize
            color: mouseArea.containsMouse ? "#16FFFFFF" : "#00000000"
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: modelAble ? 1.0 : 0.5
            Row {
                spacing: fontSize
                anchors.fill: parent
                Item {
                    width: 1
                    height: 1
                    visible: modelIndent
                }

                Rectangle {
                    width: fontSize
                    height: width
                    radius: modelMono ? width / 2 : 0
                    color: "#00000000"
                    border.width: 2
                    border.color: "white"

                    Rectangle {
                        width: 0.5 * parent.width
                        height: width
                        radius: modelMono ? width / 2 : 0
                        color: "white"
                        anchors.centerIn: parent
                        visible: modelOn
                    }
                }

                Texd {
                    color: "white"
                    text: Spell.skilltr(modelText)
                    font.pixelSize: fontSize
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                enabled: modelAble
                hoverEnabled: true
                onClicked: {
                    var i;
                    if (modelMono) {
                        // set all adjacent mono-boxes' "on" to false
                        i = index;
                        while (i - 1 >= 0 && listModel.get(i - 1).modelMono)
                            i--;
                        while (i < listModel.count && listModel.get(i).modelMono) {
                            listModel.set(i, { "modelOn": false });
                            i++;
                        }
                        modelOn = true;
                    } else {
                        modelOn = !modelOn;
                        for (i = index + 1;
                             i < listModel.count && listModel.get(i).modelIndent;
                             i++)
                            listModel.set(i, { "modelAble": modelOn });
                    }
                }
            }
        }
    }

    Column {
        id: column
        spacing: 2 * fontSize
        anchors.centerIn: parent
        Texd {
            font.pixelSize: fontSize
            color: "white"
            text: "SPECIAL"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ListView {
            id: listView
            width: frame.width
            height: listModel.count * fontSize + (listModel.count - 1) * spacing
            spacing: 0.4 * fontSize
            model: listModel
            delegate: listDelegate
        }

        Buddon {
            text: ">"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                frame.visible = false;

                var mask = 0;
                for (var i = 0; i < listModel.count; i++)
                    mask = (mask << 1) | (listModel.get(i).modelOn ? 0x1 : 0x0);
                actionTriggered(mask);
            }
        }
    }

    function activate(action) {
        var list = action.IRS_CHECK;
        listModel.clear();
        for (var i = 0; i < list.length; i++)
            listModel.append(list[i]);

        frame.visible = true;
    }
}

