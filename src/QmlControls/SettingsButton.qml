import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

Button {
    id:             control
    padding:        ScreenTools.defaultFontPixelWidth * 0.75
    hoverEnabled:   !ScreenTools.isMobile
    autoExclusive:  true
    icon.color:     textColor

    property color textColor: checked || pressed ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText

    beeCopterPalette {
        id:                 beeCopterPal
        colorGroupEnabled:  control.enabled
    }

    background: Rectangle {
        color:      beeCopterPal.buttonHighlight
        opacity:    checked || pressed ? 1 : enabled && hovered ? .2 : 0
        radius:     ScreenTools.defaultFontPixelWidth / 2
    }

    contentItem: RowLayout {
        spacing: ScreenTools.defaultFontPixelWidth

        beeCopterColoredImage {
            source: control.icon.source
            color:  control.icon.color
            width:  ScreenTools.defaultFontPixelHeight
            height: ScreenTools.defaultFontPixelHeight
        }

        beeCopterLabel {
            id:                     displayText
            Layout.fillWidth:       true
            text:                   control.text
            color:                  control.textColor
            horizontalAlignment:    beeCopterLabel.AlignLeft
        }
    }
}
