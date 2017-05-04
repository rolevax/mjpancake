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
        "<h3>Pt及段位变动</h3>" +
        "<ul>" +
        "<li>1位：应援+45，替补+60，正选+75，ACE+90</li>" +
        "<li>2位：应援+0，替补+15，正选+30，ACE+45</li>" +
        "<li>3位：±0</li>" +
        "<li>4位：3级以前-0，2级-15，1级-30，初段-45，以此类推</li>" +
        "<li>Pt为负数时，初段及以上掉段，一级及以下回复至0</li>" +
        "</ul>" +
        "<h3>R量变动</h3>" +
        "<ul>" +
        "<li>delta = (play &lt; 400 ? 1 - play * 0.002 : 0.2) " +
            "* ([30,10,-10,-30][rank] + (avgR - myR) / 40)</li>" +
        "<li>人话：对手越强收获越大，对战越多变动越小</li>" +
        "</ul>" +
        "<h3>角色的段位</h3>" +
        "<ul>" +
        "<li>就像每个ID一样，每个角色也有段位和R量（平时看不见），每次对战后都在变动</li>" +
        "<li>根据角色的段位、R量不同，该角色在不同的段位战等级场被抽到概率也不同</li>" +
        "<li>应援、替补、正选、ACE场容易抽到的角色的段位R量依次提升</li>" +
        "</ul>" +
        ""
}


