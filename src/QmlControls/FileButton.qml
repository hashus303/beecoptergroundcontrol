import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

/// File Button controls used by beeCopterFileDialog control
Rectangle {
    implicitWidth:  ScreenTools.implicitButtonWidth
    implicitHeight: ScreenTools.implicitButtonHeight
    color:          highlight ? beeCopterPal.buttonHighlight : beeCopterPal.button
    border.color:   highlight ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText

    property alias  text:       label.text
    property bool   highlight:  false

    signal clicked
    signal hamburgerClicked

    property real _margins: ScreenTools.defaultFontPixelWidth / 2

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: enabled }

    beeCopterLabel {
        id:                     label
        anchors.margins:         _margins
        anchors.left:           parent.left
        anchors.right:          hamburger.left
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        verticalAlignment:      Text.AlignVCenter
        horizontalAlignment:    Text.AlignHCenter
        color:                  highlight ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText
        elide:                  Text.ElideRight
    }

    beeCopterColoredImage {
        id:                     hamburger
        anchors.rightMargin:    _margins
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        width:                  _hamburgerSize
        height:                 _hamburgerSize
        sourceSize.height:      _hamburgerSize
        source:                 "qrc:/qmlimages/Hamburger.svg"
        color:                  highlight ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText

        property real _hamburgerSize: parent.height * 0.75
    }

    beeCopterMouseArea {
        anchors.fill:   parent
        onClicked:      parent.clicked()
    }

    beeCopterMouseArea {
        anchors.leftMargin: -_margins * 2
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        anchors.right:      parent.right
        anchors.left:       hamburger.left
        onClicked:          parent.hamburgerClicked()
    }
}
