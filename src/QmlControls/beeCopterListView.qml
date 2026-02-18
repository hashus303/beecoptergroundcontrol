import QtQuick

import beeCopter
import beeCopter.Controls

/// beeCopter version of ListVIew control that shows horizontal/vertial scroll indicators
ListView {
    id:             root
    boundsBehavior: Flickable.StopAtBounds
    clip:           true

    property color indicatorColor: beeCopterPal.text

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: enabled }

    Component.onCompleted: {
        var indicatorComponent = Qt.createComponent("beeCopterFlickableScrollIndicator.qml")
        indicatorComponent.createObject(root, { orientation: beeCopterFlickableScrollIndicator.Horizontal })
        indicatorComponent = Qt.createComponent("beeCopterFlickableScrollIndicator.qml")
        indicatorComponent.createObject(root, { orientation: beeCopterFlickableScrollIndicator.Vertical })
    }
}
