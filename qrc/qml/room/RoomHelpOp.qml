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
        "<h3>全局</h3>" +
        "<ul>" +
        "<li>F11: 全屏开关</li><li>Esc/Back：返回</li>" +
        "</ul>" +
        "<h3>打牌中</h3>" +
        "<ul>" +
        "<li>双击或右击：摸切/跳过</li>" +
        "<li>触屏缩放手势：调整手牌大小</li>" +
        "<li>按住头像：隐藏场棒供托</li>" +
        "<li>指向或按住中央方块：牌山置项</li>" +
        "</ul>" +
        "<h3>牌谱</h3>" +
        "<ul>" +
        "<li>上下滚动滚轮或左右滑动触屏：上一步/下一步</li>" +
        "</ul>"
}
