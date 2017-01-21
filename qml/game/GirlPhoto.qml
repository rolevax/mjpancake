import QtQuick 2.0
import "../widget"

Rectangle {
    id: frame

    signal rivalShotted

    property string name

    color: "#33AAAACC"

    Texd {
        color: "white"
        font.pixelSize: frame.height / 13
        text: frame.name
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: frame.height / 24
    }

    ListView {
        id: barList
        anchors.fill: parent // big is good
        anchors.bottomMargin: frame.height / 24
        verticalLayoutDirection: ListView.BottomToTop
        interactive: false // don't block mouse click
        model: ListModel { id: barModel }
        delegate: Image {
            id: barImage
            width: 0.8 * frame.width
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            source: "/pic/bar/bar" + (depoBar ? "1000" : "100") + ".png"
        }
    }

    ActionButton {
        id: rivalButton
        anchors.centerIn: parent
        visible: false
        act: "IRS_RIVAL"
        mouseArea.onClicked: {
            deactivate();
            rivalShotted();
        }
    }

    function setBars(extra, deposit) {
        var i;
        deposit /= 1000;
        if (barModel.count === 0) {
            barList.model = []; // populate
            barModel.clear();
            for (i = 0; i < deposit; i++)
                barModel.append({ depoBar: true });
            for (i = 0; i < extra; i++)
                barModel.append({ depoBar: false });
            barList.model = barModel;
        } else {
            var depoCt = 0;
            for (i = 0; i < barModel.count && barModel.get(i).depoBar; i++)
                depoCt++;
            if (depoCt > deposit) {
                // I think all 1000bars should be removed
                // since in this case deposit must be 0
                // but just be careful...
                barModel.remove(0, depoCt - deposit);
            } else {
                for (i = 0; i < deposit - depoCt; i++)
                    barModel.insert(depoCt, { depoBar: true });
            }

            // must add extra logically
            barList.model.append({ depoBar: false });
        }
    }

    function removeBars() {
        barList.model.clear();
    }

    function activateIrsRival() {
        rivalButton.visible = true;
    }

    function deactivate() {
        rivalButton.visible = false;
    }
}
