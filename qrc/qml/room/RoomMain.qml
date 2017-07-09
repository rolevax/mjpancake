import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../area"

Room {
    showReturnButton: false

    Image {
        id: titleImage
        source: "/pic/title.png"
        height: parent.height / 3
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: parent.height / 9
        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: titleEnImage
        source: "/pic/title_en.png"
        height: titleImage.height * 0.8
        anchors.top: titleImage.bottom
        anchors.horizontalCenter: titleImage.horizontalCenter
        fillMode: Image.PreserveAspectFit
    }

    SequentialAnimation {
        id: titleAnim
        running: true

        PropertyAction {
            target: titleEnImage
            property: "opacity"
            value: 0
        }

        PropertyAnimation {
            target: titleImage
            property: "opacity"
            from: 0
            to: 1
            duration: 700
            easing.type: Easing.InOutQuad
        }

        PropertyAnimation {
            target: titleEnImage
            property: "opacity"
            from: 0
            to: 1
            duration: 2000
            easing.type: Easing.InOutQuad
        }
    }

    AreaLogin {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: parent.height / 9
        visible: !PClient.loggedIn
        onSignUpClicked: {
            global.pushScene("room/RoomSignUp");
        }
    }

    Texd {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: parent.height / 9
        visible: PClient.loggedIn
        text: PClient.user.Username ? ("欢迎，" + PClient.user.Username) : ""
        font.pixelSize: global.size.middleFont
    }

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: parent.height / 9
        spacing: global.size.space

        Repeater {
            model: [
                { text: "段位", load: "Client", onlyOnline: true },
                { text: "战绩", load: "Stats", onlyOnline: true },
                { text: "单机", load: "Prac", onlyOnline: false },
                { text: "工具", load: "Tools", onlyOnline: false },
                { text: "设置", load: "Settings", onlyOnline: false }
            ]

            delegate: Buzzon {
                visible: modelData.onlyOnline ? PClient.loggedIn : true
                text: modelData.text
                textLength: 8
                onClicked: {
                    global.pushScene("room/Room" + modelData.load);
                }
            }
        }

        Buzzon {
            text: "骑马"; textLength: 8;
            onClicked: { global.rideHorse(); }
        }
    }
}
