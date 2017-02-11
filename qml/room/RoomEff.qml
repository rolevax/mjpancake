import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../game"

Room {
    id: room

    // small tile width, height
    property int tw: height / 20
    property int th: 1.35 * tw

    // big tile width and height
    property int twb: height / 13
    property int thb: 1.35 * twb

    PEff {
        id: pEff
        onDealt: {
            playerControl.deal(init);
        }
    }

    PlayerControl {
        id: playerControl
        animEnabled: true
        backColor: PGlobal.backColors[0]
        tw: room.height / 20
        twb: room.height / 13
        x: (room.width - 13 * twb) / 2;
        y: room.height - room.thb - (room.thb / 5);
        width: (room.width + 13 * twb) / 2;
        height: room.thb

        onActionTriggered: {
//            table.action(actStr, actArg)
        }
    }

    Component.onCompleted: {
        pEff.deal();
    }
}
