import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../area"
import "../game"

Room {
    id: room

    backButtonZ: 10

    Rectangle {
        anchors.centerIn: parent
        color: global.color.back
        height: areaBook.height + 2 * global.size.gap
        width: areaBook.width + 2 * global.size.gap

        Column {
            id: areaBook
            spacing: global.size.gap
            anchors.centerIn: parent

            Texd {
                visible: !areaBookRows.visible
                anchors.horizontalCenter: parent.horizontalCenter
                text: "开服时间: 每周八 19:30 ~ 21:30"
            }

            Row {
                visible: areaBookRows.visible
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: global.size.gap

                Texd {
                    text: "在线人数: " + PClient.connCt
                }

                Texd {
                    text: "对局桌数: " + PClient.tableCt
                }
            }

            Column  {
                id: areaBookRows
                visible: PClient.duringMatchTime()
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: global.size.space
                Repeater {
                    model: 2
                    delegate:  AreaBookRow {
                        anchors.right: parent.right
                        ruleId: index
                    }
                }
            }

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "零食: " + PClient.user.Food + " 贡献: " + PClient.user.CPoint
            }

            Buzzon {
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: _foodAvailable()
                text: _foodAvailable() ? "获取零食" : _foodCdStr()
                textLength: Math.max(0.7 * text.length, 12)
                onClicked: {
                    enabled = false;
                    PClient.sendCliamFood();
                }
            }
        }

        Texd {
            visible: PClient.hasMatching;
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: global.size.space
            text: "取消预约"
            color: "blue"
            font.underline: true
            font.pixelSize: global.size.smallFont

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    PClient.sendMatchCancel();
                }
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: areaBookRows.visible
        triggeredOnStart: true
        onTriggered: {
            PClient.lookAround();
        }
    }

    // backdoor for overtime play
    Shortcut {
        sequence: "F8"
        onActivated: {
            areaBookRows.visible = true;
        }
    }

    function _foodAvailable() {
        if (PClient.user.CPoint <= 0)
            return false;

        var date = new Date(PClient.user.GotFoodAt);
        if (!date)
            return  true;
        _shiftDate(date);
        return new Date() - date > 0;
    }

    function _foodCdStr() {
        if (PClient.user.CPoint <= 0)
            return "做任务得零食，详情主站";

        var date = new Date(PClient.user.GotFoodAt);
        _shiftDate(date);
        return "下次: " + date.toLocaleString();
    }

    function _shiftDate(date) {
        date.setTime(date.getTime() + 7 * 24 * 3600 * 1000);
    }
}
