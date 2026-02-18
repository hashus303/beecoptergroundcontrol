import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

Button {
    id:                 control
    autoExclusive:      true
    leftPadding:        ScreenTools.defaultFontPixelWidth
    rightPadding:       leftPadding

    property real _compIDWidth: ScreenTools.defaultFontPixelWidth * 3
    property real _hzWidth:     ScreenTools.defaultFontPixelWidth * 6
    property real _nameWidth:   nameLabel.contentWidth

    background: Rectangle {
        anchors.fill:   parent
        color:          checked ? beeCopterPal.buttonHighlight : beeCopterPal.button
    }

    property double messageHz:  0
    property int    compID:     0

    contentItem: RowLayout {
        id:         rowLayout
        spacing:    ScreenTools.defaultFontPixelWidth

        beeCopterLabel {
            text:                   control.compID
            color:                  checked ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText
            verticalAlignment:      Text.AlignVCenter
            Layout.minimumHeight:   ScreenTools.isMobile ? (ScreenTools.defaultFontPixelHeight * 2) : (ScreenTools.defaultFontPixelHeight * 1.5)
            Layout.minimumWidth:    _compIDWidth
        }
        beeCopterLabel {
            id:                     nameLabel
            text:                   control.text
            color:                  checked ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText
            Layout.fillWidth:       true
            Layout.alignment:       Qt.AlignVCenter
        }
        beeCopterLabel {
            color:                  checked ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText
            text:                   messageHz.toFixed(1) + 'Hz'
            horizontalAlignment:    Text.AlignRight
            Layout.minimumWidth:    _hzWidth
            Layout.alignment:       Qt.AlignVCenter
        }
    }

    Component.onCompleted: maxButtonWidth = Math.max(maxButtonWidth, _compIDWidth + _hzWidth + _nameWidth + (rowLayout.spacing * 2) + (control.leftPadding * 2))
}
