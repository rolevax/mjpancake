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
        "<li>大三元基本上是不二之选<ol>"+
            "<li>相比四喜、国士，只需要9次播种</li>"+
            "<li>风牌挂很多，针对三元牌的挂基本没有</li>"+
            "<li>考虑能力冲突不是怕收获不来，而是怕从一开始就没种可播</li></ol></li>"+
        "</ul>" +
        "<h3>诚哥</h3>" +
        "<ul>" +
        "<li>只留1组两面搭子，趁早清理多余的搭子和危险牌</li>"+
        "<li>钓鱼需三副露，风险大；发现配牌连抖拉2程度都没有，及时弃挂从良岂不美哉</li>"+
        "<li>钓鱼中途发现一个对子不好碰，将其拆掉，很可能会摸回另一对好碰的</li>"+
        "</ul>" +
        "<h3>玄</h3>" +
        "<ul>" +
        "<li>有4张赤牌的规则下打法基本按原作来<ol>"+
            "<li>不要鸣牌</li>"+
            "<li>不要杠，摸到四张一样的字牌就弃和</li>"+
            "<li>不要立直</li></ol></li>"+
        "</ul>" +
        "<h3>AKO</h3>" +
        "<ul>" +
        "<li>可以积极考虑从距离成型很远的地方开始鸣牌<ul>"+
            "<li>\"很远\"真的非常远<img src=\"qrc:///pic/icon/huaji.png\"/></li>"+
            "<li>小心不要会错发牌姬的深意</li></ul></li>"+
        "</ul>" +
        "<h3>Toki</h3>" +
        "<ul>" +
        "<li>优先试探正常手顺</li>"+
        "<li>优先试探默听</li>"+
        "<li>优先试探无视对手全攻</li>"+
        "</ul>" +
        "<h3>夕哥</h3>" +
        "<ul>" +
        "<li>重视打点超出普通范围，小牌一律拒听</li>"+
        "</ul>" +
        "<h3>爽帝</h3>" +
        "<ul>" +
        "<li>尽量在坐庄时开挂——除了得点，先摸牌是个很大优势</li>"+
        "<li>鸟神威的效果是成对，不是成刻，需要注意鸣牌机会</li>"+
        "</ul>" +
        ""
}


