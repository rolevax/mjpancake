import QtQuick 2.7
import QtQuick.Window 2.2
import QtMultimedia 5.7
import rolevax.sakilogy 1.0
import "area"
import "widget"

Window {
    id: window

    readonly property bool mobile: Qt.platform.os === "android"

    readonly property var global: {
        "version": "v" + PGlobal.version,
        "window": window,
        "mobile": mobile,
        "windows": Qt.platform.os === "windows",
        "size": {
            "smallFont": (mobile ? 0.030 : 0.027) * window.height,
            "middleFont": (mobile ? 0.040 : 0.032) * window.height,
            "defaultFont": (mobile ? 0.032 : 0.030) * window.height,
            "space": (mobile ? 0.009 : 0.007) * window.height,
            "gap": (mobile ? 0.054 : 0.042) * window.height
        },
        "sound": {
            "button": soundButton,
            "toggle": soundToggle,
            "select": soundSelect,
            "discard": soundDiscard,
            "bell": soundBell
        }
    }

    visible: true
    width: 1207; height: 679
    color: PGlobal.themeBack
    title: (PClient.loggedIn ? PClient.user.Username + "@" : "") + "松饼麻雀 " + global.version

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
            loader.source = "room/RoomSignUp.qml";
        }
    }

    Buzzon {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: parent.height / 9
        visible: PClient.loggedIn
        text: !!PClient.user.Username ? PClient.user.Username : ""
        textLength: 8
    }

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: parent.height / 9
        spacing: global.size.space

        Buzzon {
            text: "段位"
            textLength: 8
            visible: PClient.loggedIn
            enabled: !docButton.redDot
            onClicked: { loader.source = "room/RoomClient.qml"; }
        }

        Buzzon {
            text: "单机"
            textLength: 8
            enabled: !docButton.redDot
            onClicked: { loader.source = "room/RoomPrac.qml"; }
        }

        Buzzon {
            id: docButton
            text: "文档"
            textLength: 8
            redDot: !PGlobal.redDots.every(function(b) { return !b; })
            onClicked: { loader.source = "room/RoomHelp.qml"; }
        }

        Repeater {
            model: [
                { text: "工具", load: "Tools" },
                { text: "设定", load: "Settings" }
            ]

            delegate: Buzzon {
                text: modelData.text
                textLength: 8
                onClicked: { loader.source = "room/Room" + modelData.load + ".qml"; }
            }
        }

        Buzzon {
            text: "骑马"; textLength: 8
            onClicked: {
                if (PGlobal.mute)
                    Qt.quit();
                else
                    soundHorse.play();
            }
        }
    }

    SoundEffect {
        id: soundHorse
        source: "qrc:///sound/horse.wav"
        onPlayingChanged: { if (!playing) Qt.quit(); }
    }

    SoundEffect { id: soundButton; muted: PGlobal.mute; source: "qrc:///sound/button.wav" }
    SoundEffect { id: soundToggle; muted: PGlobal.mute; source: "qrc:///sound/toggle.wav" }
    SoundEffect { id: soundSelect; muted: PGlobal.mute; source: "qrc:///sound/select.wav" }
    SoundEffect { id: soundDiscard; muted: PGlobal.mute; source: "qrc:///sound/discard.wav" }
    SoundEffect { id: soundBell; muted: PGlobal.mute; source: "qrc:///sound/bell.wav" }

    function closeRoom() {
        loader.source = "";
        titleAnim.start();
    }

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded: {
            PGlobal.forceImmersive();
            loader.focus = true;
            item.closed.connect(closeRoom);
        }
    }

    Connections {
        target: PClient

        onStartIn: {
            if (loader.source != Qt.resolvedUrl("room/RoomClient.qml"))
                loader.source = "room/RoomClient.qml";

            loader.item.handleStartIn(tempDealer, users, choices);
        }
    }

    Buzzon {
        textLength: 8
        anchors.margins: global.size.space
        anchors.right: parent.right
        anchors.top: parent.top
        visible: PClient.hasBooking
        text: "预约中"
        onClicked: { loader.source = "room/RoomClient.qml"; }
    }

    Shortcut {
        sequence: "F11"
        onActivated: {
            if (window.visibility === Window.Windowed)
                window.visibility = Window.FullScreen;
            else if (window.visibility === Window.FullScreen)
                window.visibility = Window.Windowed;
        }
    }
}
