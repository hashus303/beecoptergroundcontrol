import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

GroupBox {
    id: control

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: enabled }

    background: Rectangle {
        y:      control.topPadding - control.padding
        width:  parent.width
        height: parent.height - control.topPadding + control.padding
        color:  beeCopterPal.windowShade
    }

    label: beeCopterLabel {
        width:  control.availableWidth
        text:   control.title
    }
}
