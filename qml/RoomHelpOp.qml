import QtQuick 2.0
import "widget"

Room {
    Texd {
        lineHeight: 1.5
        width: parent.width / 4 * 3
        anchors.centerIn: parent
        wrapMode: Text.WrapAnywhere
        horizontalAlignment: Text.AlignLeft
        text: "<h3>全局</h3>" +
              "<ul>" +
              "<li>F11: 全屏开关</li><li>Esc/Back：返回</li>" +
              "</ul>" +
              "<h3>打牌中</h3>" +
              "<ul>" +
              "<li>双击或右击：摸切/跳过</li>" +
              "</ul>" +
              "<h3>牌谱</h3>" +
              "<ul>" +
              "<li>上下滚动滚轮或左右滑动触屏：上一步/下一步</li>" +
              "</ul>"
    }
}
