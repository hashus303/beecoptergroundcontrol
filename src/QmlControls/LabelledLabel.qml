import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

RowLayout {
    property alias label:                   _labelLabel.text
    property alias labelText:              _label.text
    property real  labelPreferredWidth:    -1

    spacing: ScreenTools.defaultFontPixelWidth * 2

    beeCopterLabel {
        id:                 _labelLabel
        Layout.fillWidth:   true
    }

    beeCopterLabel {
        id:                     _label
        Layout.preferredWidth:  labelPreferredWidth
    }
}
