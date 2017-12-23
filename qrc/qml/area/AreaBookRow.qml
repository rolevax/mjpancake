import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Row {
    property int ruleId
    property var _ruleNames: [ "IH71 科学场", "IH71 经典二择" ]

    spacing: global.size.gap

    Texd {
        text: _ruleNames[ruleId]
        font.pixelSize: global.size.middleFont
        anchors.verticalCenter: parent.verticalCenter
    }

    Buzzon {
        id: bookButton
        enabled: !PClient.matchings[ruleId]
        anchors.verticalCenter: parent.verticalCenter
        textLength: 4
        text: PClient.matchings[ruleId] ? "待开" : "预约"
        onClicked: { PClient.sendMatchJoin(ruleId); }
    }

    Texd {
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: global.size.middleFont
        text: [ "零缺四", "一缺三", "二缺二", "三缺一" ][PClient.matchWaits[ruleId]]
    }
}
