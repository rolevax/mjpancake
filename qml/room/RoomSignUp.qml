import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Room {
    id: room

    property bool frozen: false

    Column {
        anchors.centerIn: parent
        spacing: global.size.space

        TexdInput {
            id: unInput
            textLength: 8
            anchors.horizontalCenter: parent.horizontalCenter
            hintText: "用户名"
            enabled: !frozen
            validator: RegExpValidator { regExp: /^.{1,16}$/ }
            KeyNavigation.tab: pwInput
            onTextChanged: {
                errorText.text = "";
            }
            onAccepted: {
                pwInput.focus = true;
            }
        }

        TexdInput {
            id: pwInput
            textLength: 8
            anchors.horizontalCenter: parent.horizontalCenter
            hintText: "密码"
            enabled: !frozen
            validator: RegExpValidator { regExp: /^.{8,}$/ }
            echoMode: TextInput.Password
            KeyNavigation.tab: pwInput2
            onTextChanged: {
                errorText.text = "";
            }
            onAccepted: {
                pwInput2.focus = true;
            }
        }

        TexdInput {
            id: pwInput2
            textLength: 8
            anchors.horizontalCenter: parent.horizontalCenter
            hintText: "密码确认"
            enabled: !frozen
            validator: RegExpValidator { regExp: /^.{8,}$/ }
            echoMode: TextInput.Password
            KeyNavigation.tab: unInput
            onTextChanged: {
                errorText.text = "";
            }
            onAccepted: {
                loginButton.clicked();
            }
        }

        Buzzon {
            id: loginButton
            textLength: 8
            anchors.horizontalCenter: parent.horizontalCenter
            text: frozen ? "注册中…" : "注册"
            enabled: (!frozen
                      && unInput.acceptableInput
                      && pwInput.acceptableInput
                      && pwInput2.acceptableInput)
            onClicked: {
                _submit();
            }
        }

        Texd {
            id: errorText
            font.pixelSize: global.size.middleFont
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item { width: 1; height: global.size.gap }

        Texd {
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            text: "用户名1～16字符<br/>" +
                  "密码8～∞字符<br/>" +
                  "避免与重要账号使用相同的用户名或密码<br/>"
        }
    }

    readonly property string huaji:
        "<img width=\"28\" height=\"28\" src=\"qrc:///pic/icon/huaji.png\"/>"

    Rectangle {
        id: license
        anchors.fill: parent
        color: PGlobal.themeBack
        Column {
            anchors.centerIn: parent
            spacing: global.size.gap

            Texd {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "<h3>入坑须知</h3>" +
                      "<br/><ol>" +
                      "<li>本作与绝大多数网游不同，属于学习交流性质。<ul>" +
                          "<li>主旨在于大家一起实验并讨论saki系列作品的设定及内涵。</li>" +
                          "<li><b>你不是\"顾客\"</b>，" +
                          "不要对\"服务\"和\"质量\"有任何期待。</li></ul></li>" +
                      "<li>本制作组毫无节操，对因使用本作产生的任何损失不负任何责任。<ul>" +
                          "<li>\"损失\”包括但不限于数据丢失/错乱/泄露、崩溃、卡死、掉线。</li>" +
                          "<li>你的索赔（诸如加pt）通常不会被接受。</li></ul></li>" +
                      "<li>不保证长期维护。<ul>" +
                          "<li>制作组可随时无理由停机或删除任何数据。</li>" +
                          "<li>玩着开心就好，认真你就输了" + huaji + "</li></ul></li>" +
                      "</ol>"
            }

            Row {
                spacing: global.size.space
                anchors.horizontalCenter: parent.horizontalCenter
                Buzzon { text: "继续入坑"; textLength: 8; onClicked: { license.visible = false; } }
                Buzzon { text: "弃坑"; onClicked: { closed(); } }
            }
        }
    }

    Rectangle {
        id: authOkScreen
        visible: false
        anchors.fill: parent
        color: PGlobal.themeBack
        Texd {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: global.size.middleFont
            text: "<a>注册成功！即将返回首页</a><br/><br/>" +
                  "<i>一入天麻深似海，从此胖次是路人</i>"
        }
    }

    Timer {
        id: authOkTimer
        interval: 5000
        onTriggered: {
            closed();
        }
    }

    Connections {
        target: PClient

        onAuthFailIn: {
            errorText.text = reason;
            room.frozen = false;
        }

        onUserChanged: {
            if (PClient.loggedIn) {
                authOkScreen.visible = true;
                authOkTimer.start();
            }
        }
    }

    Component.onCompleted: {
        if (!global.mobile)
            unInput.focus = true;
    }

    function _submit() {
        if (pwInput.text !== pwInput2.text) {
            errorText.text = "两次输入密码不一致";
            return;
        }

        frozen = true;
        PClient.signUp(unInput.text.trim(), pwInput.text);
    }
}
