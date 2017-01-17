import QtQuick 2.0
import "widget"

Room {
    Flickable {
        id: flick
        width: 0.75 * parent.width
        height: 0.8 * parent.height
        contentWidth: width
        contentHeight: text.height
        anchors.centerIn: parent
        clip: true

        Texd {
            id: text
            lineHeight: 1.5
            width: parent.width
            wrapMode: Text.WrapAnywhere
            horizontalAlignment: Text.AlignLeft
            text: blabla
        }
    }

    Texd {
        anchors.right: flick.right
        anchors.top: flick.bottom
        font.pixelSize: global.size.smallFont
        text: "页面可以上下滚动"
    }

    readonly property string huaji:
        "<img width=\"28\" height=\"28\" src=\"qrc:///pic/icon/huaji.png\"/>"

    readonly property string blabla:
        "<h3>关于制作计划</h3>" +
        "<ul>" +
        "<li>为什么要做这个<ul>"+
            "<li>有关saki的麻将游戏大多经过了简化，技能设定和原作有较大出入</li>" +
            "<li>所以想做个不做简化，如实还原的</li></ul></li>" +
        "<li>什么时候更新/更新是否有规律<ul>"+
            "<li>生产力有限+具有实验性，做不到预测更新时间</li></ul></li>" +
        "<li>是否可以添加音乐、音效、头像、立绘<ul>"+
            "<li>敬请期待</li></ul></li>" +
        "</ul>" +
        "<h3>关于角色能力</h3>" +
        "<ul>" +
        "<li>有矛盾的能力之间的优先级问题<ul>"+
            "<li>已知优先级的按已知的来，如SM连携可破笨淡序盘支配</li>" +
            "<li>优先级未知的情况下，大体上发动机会越小的越优先</li>" +
            "<li>多数能力间都是相对强弱的关系，如无必要不另行设定绝对的优先级</li>" +
            "<li>发牌姬会尽可能地让所有人的能力无冲突地同时生效</li>" +
            "</ul></li>" +
        "<li>XX角色太强/XX角色太弱/连续好几次都XXX/每次都XXX<ul>" +
            "<li>由于不存在“剧情需要”，游戏的偶然性必然大于动漫，个别几局看不出强弱</li>" +
            "<li>3次和5次说明问题的程度有巨大差别，反馈时希望给出具体次数</li>" +
            "</ul></li>" +
        "</ul>" +
        "<h3>关于规则</h3>" +
        "<ul>" +
        "<li>为毛和不了<ul>" +
            "<li>确认是否<i>无役</i>或<i>振听</i></li></ul></li>" +
        "<li>点了“终了”为毛又开始下一局<ul>" +
            "<li>按钮只表意愿，他家的尾庄top选择了续行</li></ul></li>" +
        "</ul>" +
        "<h3>关于操作</h3>" +
        "<ul>" +
        "<li>如何吃/碰/杠<ul>" +
            "<li>加杠按钮在副露上，其余的吃碰杠按钮在牌上</li>" +
            "<li>出现多种吃/碰/杠选项时，左箭头为吃，下箭头为碰，方块为杠</li></ul></li>" +
        "</ul>" +
        "</ul>"
}
