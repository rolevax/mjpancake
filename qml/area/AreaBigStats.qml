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
                                "平顺", "终素", "三杀", "独沉" ][index]
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
            text: PClient.stats[currIndex].Round + " 局"
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
                        text: [ "和了", "放铳", "副露", "立直",
                                "和点", "铳点", "副期", "立期",
                                "听牌", "听巡", "和巡", "役满" ][index]
                    }

                    Texd {
                        anchors.right: parent.right
                        anchors.rightMargin: global.size.defaultFont
                        text: _roundValue(index)
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
                        text: _yakuValue(index, 0) + "/" + _yakuValue(index, 1) +
                              "/" + _yakuValue(index, 2)
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
            text: "和了时宝牌统计\n（平均张数）\n"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            spacing: global.size.space
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: 5
                delegate: Item {
                    width: 12 * global.size.defaultFont
                    height: global.size.defaultFont

                    Texd {
                        anchors.left: parent.left
                        text: [ "表宝牌", "赤宝牌",
                                "里宝牌", "杠表宝牌", "杠里宝牌" ][index]
                    }

                    Texd {
                        anchors.right: parent.right
                        anchors.rightMargin: global.size.defaultFont
                        text: _doraValue(index)
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
                    text: _yakumanValue(index) + "次"
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
                text: _yakumanValue(15) + "次"
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
                      "三杀：他三家计分点以下A-top频率\n" +
                      "独沉：他三家计分点以上一人沉频率\n" +
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
        } else if (index === 6) { // a top
            return (stat.ATop / _playCt() * 100).toFixed(1) + "%";
        } else if (index === 7) { // a last
            return (stat.ALast / _playCt() * 100).toFixed(1) + "%";
        } else {
            return "----";
        }
    }

    function _roundValue(index) {
        var stat = PClient.stats[currIndex];
        if (stat.Round === 0) // new account, only summary
            return "---";

        var r = stat.Round;
        var keys = [
            "X13", "Xd3", "X4a", "Xt1", "Xs4", "Xd4",
            "Xcr", "Xr1", "Xth", "Xch", "X4k", "X9r",
            "W13", "W4a", "W9r", "Kzeykm"
        ];
        switch (index) {
        case 0:
            return (stat.Win / r * 100).toFixed(1) + "%";
        case 1:
            return (stat.Gun / r * 100).toFixed(1) + "%";
        case 2:
            return (stat.Bark / r * 100).toFixed(1) + "%";
        case 3:
            return (stat.Riichi / r * 100).toFixed(1) + "%";
        case 4:
            return stat.WinPoint.toFixed(1);
        case 5:
            return "-" + stat.GunPoint.toFixed(1);
        case 6:
            return stat.BarkPoint.toFixed(1);
        case 7:
            return stat.RiichiPoint.toFixed(1);
        case 8:
            return (stat.Ready / r * 100).toFixed(1) + "%";
        case 9:
            return stat.ReadyTurn.toFixed(2);
        case 10:
            return stat.WinTurn.toFixed(2);
        case 11:
            return (keys.reduce(function(s, k){return s+stat[k];}, 0) / r * 100).toFixed(2) + "%";
        default:
            return "----";
        }
    }

    function _yakuValue(index, column) {
        var stat = PClient.stats[currIndex];
        if (stat.Round === 0) // new account, only summary
            return "-";

        var keys = [
            "Rci", "Ipt", "Tmo", "Tny", "Pnf", "Ipk",
            "Y1y", "Y2y", "Y3y",
            "Jk1", "Jk2", "Jk3", "Jk4", "Bk1", "Bk2", "Bk3", "Bk4",
            "Rns", "Hai", "Hou", "Ckn", "Ss1", "It1", "Ct1",
            "Wri", "Ss2", "It2", "Ct2",
            "Ctt", "Toi", "Sak", "Skt", "Stk", "Hrt", "S3g", "H1t", "Jc2",
            "Mnh", "Jc3", "Rpk", "C1t", "Mnc"
        ];

        if (index < keys.length) {
            var key = keys[index];
            if (column === 0) { // count
                return stat[key];
            } else if (column === 1) { // freq
                var res = "" + (stat[key] / stat.Win).toFixed(3);
                return res[0] === "1" ? "1.00" : res.substr(1);
            } else { // avg han
                key += "Han";
                return stat[key].toFixed(1);
            }
        } else {
            return "---";
        }
    }

    function _doraValue(index) {
        var stat = PClient.stats[currIndex];
        switch (index) {
        case 0:
            return (stat.Dora / stat.Win).toFixed(3);
        case 1:
            return (stat.Akadora / stat.Win).toFixed(3);
        case 2:
            return (stat.Uradora / stat.Win).toFixed(3);
        case 3:
            return (stat.Kandora / stat.Win).toFixed(3);
        case 4:
            return (stat.Kanuradora / stat.Win).toFixed(3);
        default:
            return "---";
        }
    }

    function _yakumanValue(index) {
        if (PClient.stats[currIndex].Round === 0) // new account, only summary
            return 0;

        var keys = [
            "X13", "Xd3", "X4a", "Xt1", "Xs4", "Xd4",
            "Xcr", "Xr1", "Xth", "Xch", "X4k", "X9r",
            "W13", "W4a", "W9r", "Kzeykm"
        ];

        if (index < keys.length) {
            return PClient.stats[currIndex][keys[index]];
        } else {
            return "---";
        }
    }
}
