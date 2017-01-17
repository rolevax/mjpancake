import QtQuick 2.0
import rolevax.sakilogy 1.0
import "widget"

Room {
    id: room

    property bool locked: false

    property var girlIds: [ 0, 0, 0, 0 ]
    property var displayedNames: [ "???", "???", "???", "???" ]
    property int tempDealer

    PClient {
        id: pClient

        onEntryIn: {
            annText.text = ann === "" ? "正在戳戳服务器娘……" : ann;
            loginArea.visible = login;
            opArea.visible = false;
            loader.source = "";
        }

        onAuthFailIn: {
            locked = false;
            loginErrorText.text = reason;
        }

        onAuthOkIn: {
            locked = false;
            loginArea.visible = false;
            opArea.visible = true;
        }

        onStartIn: {
            room.tempDealer = tempDealer;
            console.log("qml: yeah, time to load table! tempDealer=", tempDealer);
            loader.source = "Game.qml";
        }
    }

    Texd {
        id: annText
        anchors.top: parent.top
        anchors.topMargin: global.size.gap
        anchors.horizontalCenter: parent.horizontalCenter
        text: "正在戳戳服务器娘……"
    }

    Column {
        id: opArea
        anchors.top: annText.bottom
        anchors.topMargin: global.size.gap
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: global.size.space
        visible: false

        Texd {
            anchors.horizontalCenter: parent.horizontalAlignment
            text: "欢迎，" + pClient.nickname + "!"
        }

        Item {
            width: bookButton.width
            height: bookButton.height
            anchors.horizontalCenter: parent.horizontalCenter

            Buzzon {
                id: bookButton
                textLength: 8
                text: "约"
                onClicked: {
                    visible = false;
                    pClient.book();
                }
            }

            Texd {
                anchors.centerIn: bookButton
                text: "约ing……"
                visible: !bookButton.visible
            }
        }
    }

    Column {
        id: loginArea

        anchors.top: annText.bottom
        anchors.topMargin: global.size.gap
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: global.size.space
        visible: false

        TexdInput {
            id: unInput
            anchors.horizontalCenter: parent.horizontalCenter
            textLength: 8
            hintText: "用户名"
            enabled: !locked
            opacity: locked ? 0.5 : 1
            validator: RegExpValidator { regExp: /^[[a-zA-Z0-9_\-]{4,32}$/ }
            KeyNavigation.tab: pwInput
            onVisibleChanged: {
                if (visible && !global.mobile)
                    focus = true;
            }
            onTextChanged: {
                loginErrorText.text = "";
            }
            onAccepted: {
                pwInput.focus = true;
            }
        }

        TexdInput {
            id: pwInput
            anchors.horizontalCenter: parent.horizontalCenter
            textLength: 8
            hintText: "密码"
            enabled: !locked
            opacity: locked ? 0.5 : 1
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

        Item {
            width: loginButton.width
            height: loginButton.height
            anchors.horizontalCenter: parent.horizontalCenter

            Buzzon {
                id: loginButton
                textLength: 8
                text: "蹬"
                visible: !locked && unInput.acceptableInput && pwInput.acceptableInput
                onClicked: {
                    locked = true;
                    pClient.login(unInput.text, pwInput.text);
                }
            }

            Texd {
                anchors.centerIn: loginButton
                text: "蹬ing……"
                visible: locked
            }
        }

        Texd {
            id: loginErrorText
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    function closeTable() {
        loader.source = "";
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            // need these to enable keyboard and android 'back' key inside table
            room.focus = false;
            loader.focus = true;

            item.table.tileSet = "std";
            item.table.setNames(displayedNames);
            item.table.middle.setDealer(tempDealer, true);
            item.table.closed.connect(closeTable);

            startTimer.start();
        }
    }

    Timer {
        // delay one frame to solve android crash somehow
        id: startTimer
        interval: 17
        onTriggered: {
            loader.item.startOnline(pClient);
        }
    }

    Component.onCompleted: {
        pClient.fetchAnn();
    }
}
