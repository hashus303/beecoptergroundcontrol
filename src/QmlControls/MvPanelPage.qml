import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

Rectangle {
    property bool showBorder:               true
    property real contentMargin:            ScreenTools.defaultFontPixelHeight
    default property alias contentChildren: contentContainer.data

    color:              beeCopterPal.windowTransparent
    border.color:       beeCopter.globalPalette.groupBorder
    border.width:       showBorder ? 1 : 0
    radius:             ScreenTools.defaultFontPixelHeight / 3

    Item {
        id:                   contentContainer
        anchors.fill:         parent
        anchors.margins:      contentMargin / 2
        anchors.bottomMargin: contentMargin * 2
    }
}
