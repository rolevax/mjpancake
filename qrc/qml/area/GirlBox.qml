import QtQuick 2.7
import "../widget"
import "../js/girlnames.js" as Names

Row {
    signal choosen(int girlId) // deprecated

    property int currGirlId
    property string mark
    property int defaultIndex: 0

    spacing: global.size.gap

    Texd {
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: combo.buddon.fontSize
        text: mark
    }

    GomboMenu {
        id: combo
        model: Names.availNames
        textLength: 7

        onActivated: {
            currGirlId = Names.availIds[index];
            choosen(currGirlId);
        }

        Component.onCompleted: {
            currentIndex = defaultIndex;
            activated(currentIndex);
        }
    }

    function chooseByAvalIndex(index) {
        combo.currentIndex = index;
        combo.activated(index);
    }
}
