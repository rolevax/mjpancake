import QtQuick 2.7
import "../widget"

Room {
    Fligable {
        anchors.fill: parent
        anchors.leftMargin: 0.05 * parent.width
        anchors.rightMargin: 0.05 * parent.width
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height
        blaText: blabla
    }

    readonly property string blabla:
        "<h3>茶杯</h3>" +
        "<ul>" +
        "<li>喵准大三元<ol>" +
            "<li>相比四喜、国士，只需要9次播种</li>" +
            "<li>风牌挂很多，针对三元牌的挂基本没有</li>" +
            "<li>考虑能力冲突不是怕收获不来，而是怕从一开始就没种可播</li></ol></li>" +
        "</ul>" +
        "<h3>玄</h3>" +
        "<ul>" +
        "<li>有赤牌的规则下，不立直，不暗杠，不鸣牌</li>" +
        "</ul>" +
        "<h3>怜</h3>" +
        "<ul>" +
        "<li>优先试探正常牌效/正常鸣牌/默听/全攻，尽力避免CD</li>" +
        "<li>如同半决赛，利用牌山不变定律读山坑人（这种机会比想像中要多）</li>" +
        "</ul>" +
        "<h3>夕哥</h3>" +
        "<ul>" +
        "<li>小牌一律拒听<ul>" +
            "<li>打点\"不低\"即可，并非越大越容易和</li></ul></li>" +
        "</ul>" +
        "<h3>爽帝</h3>" +
        "<ul>" +
        "<li>尽量在坐庄时开挂——除了得点，先摸牌是个很大优势</li>" +
        "<li>鸟神威的效果是成对，不是成刻，需要注意鸣牌机会</li>" +
        "<li>霞开绝一门后考虑对自己用赤云（此时对他家用赤云实属作死）</li>" +
        "</ul>" +
        ""
}


