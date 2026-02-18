import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

Text {
    font.pointSize: ScreenTools.defaultFontPointSize
    font.family:    ScreenTools.normalFontFamily
    color:          beeCopterPal.text
    antialiasing:   true

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: enabled }
}
