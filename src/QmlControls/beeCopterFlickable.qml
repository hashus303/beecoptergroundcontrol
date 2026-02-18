import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

/// beeCopter version of Flickable control that shows horizontal/vertial scroll indicators
Flickable {
    id:                     root
    boundsBehavior:         Flickable.StopAtBounds
    clip:                   true
    maximumFlickVelocity:   (ScreenTools.realPixelDensity * 25.4) * 8   // About two inches per second

    property color indicatorColor: beeCopterPal.text

    Component.onCompleted: {
        var indicatorComponent = Qt.createComponent("beeCopterFlickableScrollIndicator.qml")
        indicatorComponent.createObject(root, { orientation: beeCopterFlickableScrollIndicator.Horizontal })
        indicatorComponent = Qt.createComponent("beeCopterFlickableScrollIndicator.qml")
        indicatorComponent.createObject(root, { orientation: beeCopterFlickableScrollIndicator.Vertical })
    }
}
