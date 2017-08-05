import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../area"
import "../game"

Room {
    id: room

    property bool _playing: false
    property bool _frozen: false

    backButtonZ: 10
    showReturnButton: !_playing

    Game {
        id: game
        visible: _playing
        focus: true
        table.tileSet: "std"
        table.onClosed: { _playing = false; }
    }

    Rectangle {
        visible: !_playing
        anchors.centerIn: parent
        color: "#AA000000"
        height: areaBook.height + 2 * global.size.gap
        width: areaBook.width + 2 * global.size.gap

        Row {
            id: areaBook
            visible: !rivalChooser.visible
            spacing: global.size.space
            anchors.centerIn: parent

            Buxxon {
                text: "摸打练习"
                textLength: 6
                image: "/pic/icon/book.png"
                enabled: !_frozen
                onClicked: {
                    _playing = true;
                    game.startPrac(global.currGirlId);
                }
            }

            Buxxon {
                id: singleButton
                text: "AI战"
                textLength: 6
                image: "/pic/icon/book.png"
                enabled: !_frozen
                onClicked: {
                    rivalChooser.visible = true;
                }
            }

            Buxxon {
                text: "好友战"
                enabled: false
                textLength: 6
                image: "/pic/icon/book.png"
            }
        }

        Column {
            id: rivalChooser
            visible: false
            spacing: global.size.space
            anchors.centerIn: parent

            GirlBox {
                id: girlBox1
                z: 3
                mark: "对手1"
            }

            GirlBox {
                id: girlBox2
                z: 2
                mark: "对手2"
            }

            GirlBox {
                id: girlBox3
                z: 1
                mark: "对手3"
            }

            Item {
                width: 1
                height: 3 * global.size.space
            }

            Buzzon {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "开始"
                onClicked: {
                    rivalChooser.visible = false;
                    var aiGids = [
                        girlBox1.currGirlId,
                        girlBox2.currGirlId,
                        girlBox3.currGirlId
                    ];

                    _frozen = true;
                    PClient.sendRoomCreate(global.currGirlId, aiGids);
                }
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: !_playing
        triggeredOnStart: true
        onTriggered: {
            PClient.lookAround();
        }
    }

    Connections {
        target: PClient

        onSeatIn: {
            _handleSeatIn(room.Users, room.Gids, tempDealer);
        }
    }

    function _handleSeatIn(users, girlIds, tempDealer) {
        _playing = true;
        game.startOnline(PClient, girlIds, users, tempDealer);
        PClient.sendSeat();
    }
}
