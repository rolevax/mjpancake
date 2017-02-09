import QtQuick 2.0
import "../js/nettrans.js" as NetTrans
import "../widget"

Item {
    id: frame

    signal rivalShotted

    property string name
    property var user: null

    Rectangle {
        anchors.fill: parent
        color: "#33AAAACC"
    }

    Image {
        source: "/pic/girl/default.png"
        anchors.fill: parent
    }

    Texd {
        color: "white"
        style: Text.Outline
        styleColor: "black"
        font.pixelSize: 0.6 * nameText.font.pixelSize
        text: user == null ? ""
                           : "暂无称号\n" + user.Username + " "
                             + NetTrans.level(user.Level) + " " + NetTrans.rating(user.Rating)
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: frame.height / 24
    }

    Texd {
        id: nameText
        color: "white"
        style: Text.Outline
        styleColor: "black"
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
