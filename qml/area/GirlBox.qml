import QtQuick 2.0
import "../widget"
import "../js/girlnames.js" as Names

Row {
    signal choosen(int girlId)
    property string mark
    property int defaultIndex: 0

    Texd {
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: combo.buddon.fontSize
        width: 2.2 * combo.buddon.fontSize;
        text: mark
    }

    GomboMenu {
        id: combo
        model: Names.availNames
        textLength: 7
        onActivated: { choosen(Names.availIds[index]); }
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
