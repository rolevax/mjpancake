import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"

Column {
    id: frame

    property bool frozen: false

    spacing: global.size.space

    TexdInput {
        id: unInput
        textLength: 8
        hintText: "用户名"
        text: PGlobal.savedUsername
        enabled: !frozen
        validator: RegExpValidator { regExp: /^.{1,32}$/ }
        KeyNavigation.tab: pwInput
        onTextChanged: {
            loginErrorText.text = "";
        }
        onAccepted: {
            pwInput.focus = true;
        }
    }

    TexdInput {
        id: pwInput
        textLength: 8
        hintText: "密码"
        text: PGlobal.savedPassword
        enabled: !frozen
        validator: RegExpValidator { regExp: /^.{8,32}$/ }
        echoMode: TextInput.Password
        KeyNavigation.tab: unInput
        onTextChanged: {
            loginErrorText.text = "";
        }
        onAccepted: {
            loginButton.clicked();
        }
    }

    Buzzon {
        id: loginButton
        textLength: 8
        text: frozen ? "灵压吓人中…" : "上线"
        enabled: !frozen && unInput.acceptableInput && pwInput.acceptableInput
        onClicked: {
            frozen = true;
            loginErrorText.text = "";
            PClient.login(unInput.text.trim(), pwInput.text);
        }
    }

    Rectangle {
        visible: !!loginErrorText.text
        width: frame.width
        height: loginErrorText.height
        color: global.color.back

        Texd {
            id: loginErrorText
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Connections {
        target: PClient

        onAuthFailIn: {
            loginErrorText.text = reason;
            frame.frozen = false;
        }

        onConnError: {
            loginErrorText.text = "连接错误";
            frame.frozen = false;
        }

        onUserChanged: {
            if (PClient.loggedIn) {
                PGlobal.savedUsername = PClient.user.Username;
                if (PGlobal.savePassword)
                    PGlobal.savedPassword = pwInput.text;
            } else {
                frame.frozen = false;
            }
        }
    }
}
