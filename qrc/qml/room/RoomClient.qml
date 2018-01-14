import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../area"
import "../game"

Room {
    id: room

    property bool _playing: false

    backButtonZ: 10
    showReturnButton: !_playing

    Rectangle {
        visible: !_playing
        anchors.centerIn: parent
        color: global.color.back
        height: areaBook.height + 2 * global.size.gap
        width: areaBook.width + 2 * global.size.gap

        Column {
            id: areaBook
            spacing: global.size.gap
            anchors.centerIn: parent

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: global.size.gap

                Texd {
                    text: "在线人数: " + PClient.connCt
                }

                Texd {
                    text: "对局桌数: ?"
                }
            }

            Column  {
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
            anchors.bottom: parent.border
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
        running: !_playing
        triggeredOnStart: true
        onTriggered: {
            PClient.lookAround();
        }
    }

    Connections {
        target: PClient

        onTableInitRecved: {
            // historical, useless now, remove someday
            // as RoomGameOnline is pushed when start,
            // this room is unloaded totally then
            _playing = true;
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
