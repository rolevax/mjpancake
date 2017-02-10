import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Column {
    id: opArea
    spacing: global.size.space

    property var _gradeNames: [ "应援", "替补", "正选", "ＡＣＥ" ]
    property int _currGrade: 0

    Texd {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "在线：" + PClient.connCt
    }

    Item { width:1; height: global.size.gap }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: global.size.space

        Repeater {
            id: repSelect
            model: 4
            delegate: Buzzon {
                id: dButton
                text: _gradeNames[index]
                onClicked: {
                    selectBar.x = x;
                    selectBar.width = width;
                    _currGrade = index;
                }
            }
        }
    }

    Rectangle {
        id: selectBar
        // size set by Component.onCompleted
        radius: 0.5 * height
        color: PGlobal.themeText
        opacity: 0.5

        Behavior on x {
            PropertyAnimation {
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }
    }

    Item { width:1; height: global.size.gap }

    Repeater {
        id: repBooks
        model: 4
        delegate: AreaBookRow {
            visible: index === _currGrade
            bookType: [ "D", "C", "B", "A" ][index] + "S71"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    function popBookButtons() {
        for (var i = 0; i < 4; i++) {
            repBooks.itemAt(i).booking = false;
        }
    }

    Component.onCompleted: {
        // TODO use user's highest grade
        var dButton = repSelect.itemAt(0);
        selectBar.width = dButton.width;
        selectBar.height = 0.15 * dButton.height;
    }
}
