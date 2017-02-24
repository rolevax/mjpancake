import QtQuick 2.7

Item {
    id: frame

    signal fired

    // width set by parent
    height: global.size.space
    visible: false

    Rectangle {
        id: timeBar
        height: parent.height
        color: width > 0.7 * frame.width ? "green"
                                         : width > 0.3 * frame.width ? "orange" : "red"
        anchors.right: parent.right

        SequentialAnimation {
            id: timeBarAnim

            PauseAnimation { duration: 5000 }

            ScriptAction {
                script: {
                    frame.visible = true;
                    timeBar.width = frame.width;
                }
            }

            NumberAnimation {
                target: timeBar
                property: "width"
                to: 0
                duration: 5000
            }

            ScriptAction{
                script: {
                    fired();
                }
            }
        }
    }

    function timeDown() {
        timeBarAnim.start();
    }

    function cancel() {
        timeBarAnim.stop();
        frame.visible = false;
    }
}
