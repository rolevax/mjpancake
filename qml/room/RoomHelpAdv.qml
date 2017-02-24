import QtQuick 2.0
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
        "<li>大三元基本上是不二之选<ol>" +
            "<li>相比四喜、国士，只需要9次播种</li>" +
            "<li>风牌挂很多，针对三元牌的挂基本没有</li>" +
            "<li>考虑能力冲突不是怕收获不来，而是怕从一开始就没种可播</li></ol></li>" +
        "</ul>" +
        "<h3>诚哥</h3>" +
        "<ul>" +
        "<li>若要钓鱼，配牌之后可不能习惯性地从字牌开始切<ul>" +
            "<li>应该只留1组两面搭子，其余的搭子全部拆掉，中张浮牌一个不留，早巡之内清理干净</li>" +
            "<li>与之相反，孤张字牌能留的都留住</li></ul></li>" +
        "<li>钓鱼中途发现一个对子不好碰，要及时将其拆掉——很可能会摸回另一对好碰的</li>" +
        "<li>基本放弃平和，根据配牌中的dora个数在钓鱼/弃和中二选一</li>" +
        "</ul>" +
        "<h3>玄</h3>" +
        "<ul>" +
        "<li>有4张赤牌的规则下打法基本按原作来<ol>" +
            "<li>不要鸣牌</li>"+
            "<li>不要杠，摸到四张一样的字牌就弃和</li>" +
            "<li>不要立直</li></ol></li>" +
        "</ul>" +
        "<h3>AKO</h3>" +
        "<ul>" +
        "<li>可以积极考虑从距离成型很远的地方开始鸣牌<ul>" +
            "<li>\"很远\"真的非常远<img src=\"qrc:///pic/icon/huaji.png\"/></li>" +
            "<li>小心不要会错发牌姬的深意</li></ul></li>"+
        "</ul>" +
        "<h3>Toki</h3>" +
        "<ul>" +
        "<li>如同半决赛，利用牌山不变定律读山坑人（这种机会比想像中要多）</li>" +
        "</ul>" +
        "<h3>夕哥</h3>" +
        "<ul>" +
        "<li>小牌一律拒听</li>" +
        "</ul>" +
        "<h3>爽帝</h3>" +
        "<ul>" +
        "<li>尽量在坐庄时开挂——除了得点，先摸牌是个很大优势</li>" +
        "<li>鸟神威的效果是成对，不是成刻，需要注意鸣牌机会</li>" +
        "<li>霞开绝一门后考虑对自己用赤云（此时千万不要对他家用赤云）</li>" +
        "</ul>" +
        ""
}


