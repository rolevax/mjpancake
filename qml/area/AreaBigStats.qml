import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Item {
    id: frame

    property int currIndex: 0

    Column {
        visible: tabPager.currIndex === 0
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -global.size.gap
        spacing: global.size.space

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
            text: _playCt() + " 战"
        }

        Grid {
            anchors.horizontalCenter: parent.horizontalCenter
            rows: 4
            flow: Grid.TopToBottom
            spacing: global.size.space

            Repeater {
                model: 8
                delegate: Item {
                    width: 7 * global.size.defaultFont
                    height: global.size.defaultFont

                    Texd {
                        anchors.left: parent.left
                        text: [ "一位", "二位", "三位", "四位",
                                "平顺", "终素", "击飞", "三杀" ][index]
                    }

                    Texd {
                        anchors.right: parent.right
                        anchors.rightMargin: global.size.defaultFont
                        text: _tableValue(index)
                    }
                }
            }
        }

        Item { width: 1; height: global.size.gap }

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "23333" + " 局"
        }

        Grid {
            anchors.horizontalCenter: parent.horizontalCenter
            rows: 4
            flow: Grid.TopToBottom
            spacing: global.size.space

            Repeater {
                model: 12
                delegate: Item {
                    width: 7 * global.size.defaultFont
                    height: global.size.defaultFont

                    Texd {
                        anchors.left: parent.left
                        text: [ "和率", "铳率", "副率", "立率",
                                "和点", "铳点", "副期", "立期",
                                "和巡", "听巡", "开杠", "役满" ][index]
                    }

                    Texd {
                        anchors.right: parent.right
                        anchors.rightMargin: global.size.defaultFont
                        text: "23.3%"
                    }
                }
            }
        }

        Item { width: 1; height: global.size.gap }

        Buzzon {
            anchors.horizontalCenter: parent.horizontalCenter
            textLength: 6
            text: "缩略语说明"
            onClicked: { rectExplain.visible = true; }
        }
    }

    Column {
        visible: tabPager.currIndex === 1
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -global.size.gap
        spacing: global.size.space

        Texd {
            text: "和了役统计 （次数/频率/平均复合翻）"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Grid {
            rows: 14
            flow: Grid.TopToBottom
            spacing: global.size.space
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: 42
                delegate: Item {
                    width: 0.3 * frame.width
                    height: global.size.defaultFont

                    Texd {
                        anchors.left: parent.left
                        text: [ "立直", "一发", "门前清自摸和", "断么九", "平和", "一杯口",
                                "役牌白", "役牌发", "役牌中",
                                "自风东", "自风南", "自风西", "自风北",
                                "场风东", "场风南", "场风西", "场风北",
                                "岭上开花", "海底捞月", "河底捞鱼", "枪杠",
                                "三色同顺/食", "一气通贯/食", "混全带么九/食",
                                "两立直", "三色同顺/门", "一气通贯/门", "混全带么九/门",
                                "七对子", "对对和", "三暗刻",
                                "三杠子", "三色同刻", "混老头", "小三元",
                                "混一色/食", "纯全带么九/食",
                                "混一色/门", "纯全带么九/门", "二杯口",
                                "清一色/食", "清一色/门"
                        ][index]
                    }

                    Texd {
                        anchors.right: parent.right
                        anchors.rightMargin: global.size.defaultFont
                        text: "177/.233/1.3"
                    }
                }
            }
        }
    }


    Column {
        visible: tabPager.currIndex === 2
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -global.size.gap
        spacing: global.size.space

        Texd {
            text: "和了时宝牌统计\n（平均张数/平均复合翻）"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            spacing: global.size.space
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: 5
                delegate: Item {
                    width: 14 * global.size.defaultFont
                    height: global.size.defaultFont

                    Texd {
                        anchors.left: parent.left
                        text: [ "表宝牌", "赤宝牌",
                                "里宝牌", "杠表宝牌", "杠里宝牌" ][index]
                    }

                    Texd {
                        anchors.right: parent.right
                        anchors.rightMargin: global.size.defaultFont
                        text: "1.7/3.7"
                    }
                }
            }
        }
    }

    Grid {
        visible: tabPager.currIndex === 3
        rows: 8
        flow: Grid.TopToBottom
        spacing: global.size.space
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -global.size.gap

        Repeater {
            model: 15
            delegate: Item {
                width: 18 * global.size.defaultFont
                height: global.size.defaultFont

                Texd {
                    anchors.left: parent.left
                    text: "役满・" + [ "国士无双", "大三元", "四暗刻", "字一色",
                                      "小四喜", "大四喜", "清老头", "绿一色",
                                      "天和", "地和", "四杠子", "九莲宝灯",
                                      "国士无双・十三面", "四暗刻・单骑", "纯正・九莲宝灯"][index] + "・炸裂"
                }

                Texd {
                    anchors.right: parent.right
                    anchors.rightMargin: global.size.defaultFont
                    text: "17" + "次"
                }
            }
        }

        Item {
            width: 18 * global.size.defaultFont
            height: global.size.defaultFont

            Texd {
                anchors.left: parent.left
                text: "真・奥义・累计役满・炸裂"
            }

            Texd {
                anchors.right: parent.right
                anchors.rightMargin: global.size.defaultFont
                text: "17" + "次"
            }
        }
    }

    Rectangle {
        id: rectExplain
        visible: false
        anchors.centerIn: parent
        width: 0.7 * parent.width
        height: 0.7 * parent.height
        border.width: 1
        border.color: PGlobal.themeText
        color: PGlobal.themeBack

        Column {
            anchors.centerIn: parent
            spacing: global.size.gap

            Texd {
                text: "平顺：平均顺位\n" +
                      "终素：终局时平均素点\n" +
                      "击飞：击飞他家频率（并非被击飞）\n" +
                      "三杀：他三家负分A-Top频率\n" +
                      "和/铳/副/立率：分别为和了、放铳、副露、立直频率\n" +
                      "和/铳点：和了/放铳平均点数\n" +
                      "副/立期：副露/立直后点数得失期望值\n" +
                      "和/听巡：平均和了/听牌巡目\n"
            }

            Buzzon {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "喵"
                onClicked: { rectExplain.visible = false; }
            }
        }
    }

    TabBager {
        id: tabPager
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        model: [ "打麻", "将真", "ＴＭ", "开心" ]
    }

    function _rankPercent(r) {
        var ranks = PClient.stats[currIndex].Ranks;
        var play = ranks[0] + ranks[1] + ranks[2] + ranks[3];
        return ((ranks[r] / play) * 100).toFixed(1) + "%";
    }

    function _playCt() {
        var ranks = PClient.stats[currIndex].Ranks;
        return ranks[0] + ranks[1] + ranks[2] + ranks[3];
    }

    function _tableValue(index) {
        var stat = PClient.stats[currIndex];
        if (0 <= index && index < 4) {
            return (stat.Ranks[index] / _playCt() * 100).toFixed(1) + "%";
        } else if (index === 4) { // average rank
            var ranks = stat.Ranks;
            var sum = 1 * ranks[0] + 2 * ranks[1] + 3 * ranks[2] + 4 * ranks[3];
            return (sum / _playCt()).toFixed(2);
        } else if (index === 5) { // average point
            return stat.AvgPoint.toFixed(0);
        } else {
            return "----"
        }
    }
}
