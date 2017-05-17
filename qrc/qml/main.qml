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
                { text: "单机", load: "Prac", onlyOnline: false }
            ]

            delegate: Buzzon {
                visible: modelData.onlyOnline ? PClient.loggedIn : true
                text: modelData.text
                textLength: 8
                enabled: !docButton.redDot
                onClicked: { loader.source = "room/Room" + modelData.load + ".qml"; }
            }
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
                { text: "设置", load: "Settings" }
            ]

            delegate: Buzzon {
                text: modelData.text
                textLength: 8
                enabled: !docButton.redDot
                onClicked: { loader.source = "room/Room" + modelData.load + ".qml"; }
            }
        }

        Buzzon {
            text: "骑马"; textLength: 8; enabled: !docButton.redDot
            onClicked: { rideHorse(); }
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
		source: "room/RoomSplash.qml"
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
        id: bookingButton
        textLength: 8
        anchors.margins: global.size.space
        anchors.right: parent.right
        anchors.top: parent.top
        visible: PClient.hasBooking
        text: "预约中 " + formatElapse(bookTimer.elapse)
        onClicked: { loader.source = "room/RoomClient.qml"; }

        Timer {
            id: bookTimer
            property int elapse: 0
            interval: 1000
            repeat: true
            onTriggered: { elapse++; }
            running: bookingButton.visible
            onRunningChanged: { if (!running) elapse = 0; }
        }
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

    onClosing: {
        rideHorse();
        close.accepted = false;
    }

    Timer {
        id: horseTimer
        interval: 3000
        onTriggered: { Qt.quit(); }
    }

    function rideHorse() {
        loader.source = "room/RoomQuit.qml";
        if (PGlobal.mute) {
            horseTimer.start();
        } else {
            soundHorse.play();
        }
    }

    function formatElapse(elapse) {
        var date = new Date(null);
        date.setSeconds(elapse);
        return date.toISOString().substr(14, 5);
    }
}
