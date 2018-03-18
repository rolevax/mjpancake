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
        "color": {
            "text": "#BBBBBB",
            "back": "#99000000",
            "light": "#44AAAAAA"
        },
        "sound": {
            "button": soundButton,
            "toggle": soundToggle,
            "select": soundSelect,
            "discard": soundDiscard,
            "bell": soundBell
        },
        "pushScene": pushScene,
        "reloadBackground": reloadBackground,
    }

    property var _roomStack: []
    property var _onPushed: null

    visible: true
    width: 1207; height: 679
    color: global.color.back
    title: _getTitle()

    Image {
        id: background
        anchors.fill: parent
        cache: false
        // NOTE: if you are publishing a MOD,
        // please make your app look clearly different from the upstream version
        // in order to avoid any misunderstanding from the audience.
        source: PGlobal.official ? "image://impro/background" : ""
    }

    SoundEffect { id: soundButton; muted: PGlobal.mute; source: "qrc:///sound/button.wav" }
    SoundEffect { id: soundToggle; muted: PGlobal.mute; source: "qrc:///sound/toggle.wav" }
    SoundEffect { id: soundSelect; muted: PGlobal.mute; source: "qrc:///sound/select.wav" }
    SoundEffect { id: soundDiscard; muted: PGlobal.mute; source: "qrc:///sound/discard.wav" }
    SoundEffect { id: soundBell; muted: PGlobal.mute; source: "qrc:///sound/bell.wav" }

    Loader {
        id: loader
        anchors.fill: parent
        source: "room/RoomLogin.qml"
        onLoaded: {
            PGlobal.forceImmersive();
            loader.focus = true;
            item.closed.connect(popScene);
            if (!!_onPushed) {
                _onPushed(item);
                _onPushed = null;
            }
        }

        onStatusChanged: {
            // deprecated, now there won't be error in login page
            if (status == Loader.Error && (source == "qrc:/qml/room/RoomLogin.qml")) {
                setSource("room/RoomNetError.qml");
            }
        }
    }

    Buzzon {
        id: bookingButton
        textLength: 8
        anchors.margins: global.size.space
        anchors.right: parent.right
        anchors.top: parent.top
        visible: PClient.hasMatching
        text: "预约中 " + _formatElapse(bookTimer.elapse)

        Timer {
            id: bookTimer
            property int elapse: 0
            interval: 1000
            repeat: true
            running: bookingButton.visible
            onTriggered: {
                elapse++;
            }
            onRunningChanged: {
                if (!running) {
                    elapse = 0;
                }
            }
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

    Connections {
        target: PClient

        onRemoteClosed: {
            _roomStack = [];
            loader.source = "room/RoomLogin.qml";
        }

        onTableInitRecved: {
            pushScene("room/RoomGameOnline", function(item) {
                item.startChoose(matchResult, choices, foodCosts);
            });
        }
    }

    function pushScene(name, onPushed) {
        _roomStack.push(loader.source);
        if (!!onPushed) {
            _onPushed = onPushed;
        }
        loader.source = name + ".qml";
    }

    function popScene() {
        var top = _roomStack.pop();
        loader.source = top;
    }

    function reloadBackground() {
        var bak = background.source;
        background.source = "";
        background.source = bak;
    }

    function _getTitle() {
        if (PGlobal.official) {
            return (PClient.loggedIn ? PClient.user.Username + "@" : "") + "松饼麻雀 " + PGlobal.version;
        } else {
            return "松饼麻雀 第三方修改版";
        }
    }

    function _formatElapse(elapse) {
        var date = new Date(null);
        date.setSeconds(elapse);
        return date.toISOString().substr(14, 5);
    }
}
