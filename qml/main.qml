import QtQuick 2.4
import QtQuick.Window 2.2
import rolevax.sakilogy 1.0

Window {
    id: window

    readonly property bool mobile: Qt.platform.os === "android"

    readonly property var global: {
        "version": "v0.6.2",
        "window": window,
        "mobile": mobile,
        "windows": Qt.platform.os === "windows",
        "size": {
            "smallFont": (mobile ? 0.030 : 0.027) * window.height,
            "middleFont": (mobile ? 0.040 : 0.032) * window.height,
            "defaultFont": (mobile ? 0.032 : 0.030) * window.height,
            "space": (mobile ? 0.009 : 0.007) * window.height,
            "gap": (mobile ? 0.054 : 0.042) * window.height
        }
    }

    visible: true
    width: 1207; height: 679
    color: PGlobal.themeBack
    title: "Sakilogy " + global.version

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

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: parent.height / 9
        spacing: global.size.space

        /*
        Buddon {
            text: "     牌效     "
            onClicked: { loader.source = "RoomPrac.qml"; }
        }
        */

        Buzzon {
            text: "情报"
            textLength: 8
            onClicked: { loader.source = "RoomHelp.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "对局"
            textLength: 8
            onClicked: { loader.source = "RoomGameFree.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        /*
        Buzzon {
            text: "   手牌生成   "
            onClicked: { loader.source = "RoomGen.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }
        */

        Buzzon {
            text: "牌谱"
            textLength: 8
            onClicked: { loader.source = "RoomReplay.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "设定"
            textLength: 8
            onClicked: { loader.source = "RoomSettings.qml"; }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Buzzon {
            text: "骑马"
            textLength: 8
            onClicked: { Qt.quit() }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    function closeRoom() {
        loader.source = "";
        titleAnim.start();
    }

    Loader {
        id: loader
        anchors.fill: parent
        focus: true
        onLoaded: {
            item.closed.connect(closeRoom);
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_F11) {
                if (window.visibility === Window.Windowed)
                    window.visibility = Window.FullScreen;
                else if (window.visibility === Window.FullScreen)
                    window.visibility = Window.Windowed;
                event.accepted = true;
            }
        }
    }
}
