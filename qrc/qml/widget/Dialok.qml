import QtQuick 2.7
import rolevax.sakilogy 1.0

Rectangle {
    id: frame

    property string text
    property string hint: ""
    property real fontSize: global.size.middleFont
    property int horizontalAlignment: Text.AlignLeft

    visible: !!hint && PGlobal.hints[hint]
    anchors.centerIn: parent
    width: window.width
    height: 0.5 * window.height
    color: global.color.back

    Column {
        anchors.centerIn: parent
        spacing: global.size.gap

        Texd {
            text: frame.text
            font.pixelSize: frame.fontSize
            horizontalAlignment: frame.horizontalAlignment
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: global.size.gap

            Buzzon {
                anchors.verticalCenter: parent.verticalCenter
                text: "喵"
                onClicked: {
                    frame.visible = false;
                    if (checkBoxNoMoreHint.checked) {
                        //
                    }
                }
            }

            ChegBox {
                id: checkBoxNoMoreHint
                anchors.verticalCenter: parent.verticalCenter
                visible: !!frame.hint
                text: "不再提示"
            }
        }
    }
}
