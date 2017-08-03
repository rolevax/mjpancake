import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../game"
import "../widget"

Rectangle {
    id: frame

    property var users
    property var girlIds
    property bool showReady: false
    property var _showOrder: [ 0, 1, 2, 3 ]

    signal readyClicked

    anchors.fill: parent
    color: global.color.back
    visible: false

    Row {
        id: photos
        anchors.centerIn: parent
        spacing: global.size.gap
        Repeater {
            id: rep
            model: 4
            delegate: GirlPhoto {
                width: 0.6 * height
                height: 0.5 * frame.height
                opacity: 0.0
                girlId: girlIds[index]
                user: users[index]
            }
        }
    }

    Texd {
        id: blaText
        visible: !anim.running && !readyButton.visible
        anchors.top: photos.bottom
        anchors.topMargin: global.size.gap
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: global.size.middleFont
        text: "解说吹水中"
        SequentialAnimation on opacity {
            PropertyAnimation { to: 0.2; duration: 500 }
            PropertyAnimation { to: 1.0; duration: 500 }
            loops: Animation.Infinite
            running: true
        }
    }

    TimeBar {
        id: timeBar
        anchors.left: photos.left
        anchors.right: photos.right
        anchors.top: photos.bottom
        onFired: { _clickReady(); }
    }

    Buzzon {
        id: readyButton
        visible: showReady && !anim.running
        anchors.top: photos.bottom
        anchors.topMargin: global.size.gap
        anchors.horizontalCenter: parent.horizontalCenter
        text: "入座"
        textLength: 8
        onClicked: { _clickReady(); }
        onVisibleChanged: { if (visible) timeBar.timeDown(); }
    }

    SequentialAnimation {
        id: anim

        ScriptAction {
            script: {
                for (var i = 0; i < 3; i++) {
                    var r = Math.floor(Math.random() * (4 - i))
                    var tmp = _showOrder[r];
                    _showOrder[r] = _showOrder[i];
                    _showOrder[i] = tmp;
                }

                frame.visible = true;
            }
        }

        PauseAnimation { duration: 500 }

        ScriptAction {
            script: {
                rep.itemAt(_showOrder[0]).opacity = 1.0;
            }
        }

        PauseAnimation { duration: 500 }

        ScriptAction {
            script: {
                rep.itemAt(_showOrder[1]).opacity = 1.0;
            }
        }

        PauseAnimation { duration: 500 }

        ScriptAction {
            script: {
                rep.itemAt(_showOrder[2]).opacity = 1.0;
            }
        }

        PauseAnimation { duration: 500 }

        ScriptAction {
            script: {
                rep.itemAt(_showOrder[3]).opacity = 1.0;
            }
        }

        PauseAnimation { duration: 500 }
    }

    function _clickReady() {
        showReady = false;
        timeBar.cancel();
        readyClicked();
    }

    function splash() {
        anim.start();
    }
}
