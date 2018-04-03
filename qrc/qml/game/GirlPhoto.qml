import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../js/girlnames.js" as Names
import "../js/nettrans.js" as NetTrans
import "../widget"

Item {
    id: frame

    property alias source: image.source

    property var girlKey: {
        "id": -1,
        "path": "",
    }

    property var user: null
    property bool cache: true

    visible: girlKey && girlKey.id !== -1

    Image {
        id: image
        source: girlKey ? ("image://impro/photo/" + girlKey.id + "/" + girlKey.path) : ""
        anchors.fill: parent
        cache: frame.cache
    }

    Texd {
        color: "white"
        style: Text.Outline
        styleColor: "black"
        font.pixelSize: 0.65 * nameText.font.pixelSize
        text: user == null ? "" : user.Username
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
        text: Names.getName(girlKey, PEditor)
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
            height: 0.1 * width
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !barMouseArea.containsPress
            fillMode: Image.Stretch
            source: "/pic/bar/bar" + (depoBar ? "1000" : "100") + ".png"
        }
        MouseArea {
            id: barMouseArea
            anchors.fill: parent
            propagateComposedEvents: true
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
}
