import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Column {
    id: opArea
    spacing: global.size.space

    property var _gradeNames: [ "应援", "替补", "正选", "ＡＣＥ" ]

    Texd {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "<ul>" +
              "<li>预约后人齐即开</li>" +
              "<li>等待期间可返回进行单机游戏</li>" +
              "<li>部分角色只在上位战区出没</li>" +
              "</ul>"
    }

    TabBager {
        id: tabPager
        anchors.horizontalCenter: parent.horizontalCenter
        model: _gradeNames
    }

    Texd {
        anchors.horizontalCenter: parent.horizontalCenter
        text: [ "四段R1800未满", "1级以上", "四段R1800", "七段R2000" ][tabPager.currIndex]
    }

    Item { width: 1; height: 2 * global.size.space }

    Repeater {
        id: repBooks
        model: 4
        delegate: AreaBookRow {
            visible: index === tabPager.currIndex
            bookType: index
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Item { width: 1; height: 2 * global.size.space }

    Buzzon {
        id: cancelButton
        text: "取消预约"
        textLength: 6
        enabled: PClient.hasBooking
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: { PClient.unbook(); }
    }

    Component.onCompleted: {
        var level = PClient.user.Level;
        var rating = PClient.user.Rating;
        var max = 0;
        if (level >= 16 && rating >= 2000.0)
            max = 3;
        else if (level >= 13 && rating >= 1800.0)
            max = 2;
        else if (level >= 9)
            max = 1;
        tabPager.currIndex = max;
    }
}
