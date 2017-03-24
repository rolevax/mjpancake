import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Column {
    id: opArea
    spacing: global.size.gap

    property var _gradeNames: [ "应援", "替补", "正选", "ＡＣＥ" ]

    Texd {
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: "预约后人齐即开，等待期间可进行单机游戏\n" +
              "应援、替补、正选、ACE区内能抽到的角色依次增强\n" +
              "提高段位可进入高级战区"
    }

    TabBager {
        id: tabPager
        anchors.horizontalCenter: parent.horizontalCenter
        model: _gradeNames
    }

    Repeater {
        id: repBooks
        model: 4
        delegate: AreaBookRow {
            visible: index === tabPager.currIndex
            bookType: index
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

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
