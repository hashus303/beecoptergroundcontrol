import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

RowLayout {
    property string label:                   fact.shortDescription
    property alias  fact:                    _factLabel.fact
    property real   labelPreferredWidth: -1
    property alias  factLabelShowUnits:      _factLabel.showUnits
    property alias  factLabel:               _factLabel

    spacing: ScreenTools.defaultFontPixelWidth * 2

    beeCopterLabel {
        Layout.fillWidth:   true
        text:               label
    }

    FactLabel {
        id:                     _factLabel
        Layout.preferredWidth:  labelPreferredWidth
    }
}
