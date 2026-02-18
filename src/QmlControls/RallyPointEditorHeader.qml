import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

Rectangle {
    id:     outerEditorRect
    height: innerEditorRect.y + innerEditorRect.height + (_margin * 2)
    radius: _radius
    color:  beeCopterPal.missionItemEditor

    property var controller ///< RallyPointController

    readonly property real  _margin: ScreenTools.defaultFontPixelWidth / 2
    readonly property real  _radius: ScreenTools.defaultFontPixelWidth / 2

    beeCopterLabel {
        id:                 editorLabel
        anchors.margins:    _margin
        anchors.left:       parent.left
        anchors.top:        parent.top
        text:               qsTr("Rally Points")
    }

    Rectangle {
        id:                 innerEditorRect
        anchors.margins:    _margin
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        editorLabel.bottom
        height:             infoLabel.height + (_margin * 2)
        color:              beeCopterPal.windowShadeDark
        radius:             _radius

        beeCopterLabel {
            id:                 infoLabel
            anchors.margins:    _margin
            anchors.top:        parent.top
            anchors.left:       parent.left
            anchors.right:      parent.right
            wrapMode:           Text.WordWrap
            font.pointSize:     ScreenTools.smallFontPointSize
            text:               qsTr("Rally Points provide alternate landing points when performing a Return to Launch (RTL).\n\nClick on the map to add Rally Points.")
        }
    }
}
