import QtQuick 2.7
import QtQuick.Window 2.2
import QtMultimedia 5.7
import rolevax.sakilogy 1.0
import "area"
import "widget"

Window {
    id: window

    readonly property bool mobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

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
        },
        "pushScene": pushScene,
        "rideHorse": rideHorse
    }

    property var _roomStack: []

    visible: true
    width: 1207; height: 679
    color: PGlobal.themeBack
    title: (PClient.loggedIn ? PClient.user.Username + "@" : "") + "松饼麻雀 " + global.version

    Image{
        id: background
        anchors.fill: parent
        source: "image://impro/background"
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

    Loader {
        id: loader
        anchors.fill: parent
        source: "room/RoomMain.qml"
        onLoaded: {
            PGlobal.forceImmersive();
            loader.focus = true;
            item.closed.connect(popRoom);
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

    function pushScene(name) {
        _roomStack.push(loader.source);
        loader.source = name + ".qml";
    }

    function popRoom() {
        var top = _roomStack.pop();
        loader.source = top;
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
