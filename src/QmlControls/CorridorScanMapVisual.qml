import QtQuick
import QtQuick.Controls
import QtLocation
import QtPositioning

import beeCopter
import beeCopter.Controls
import beeCopter.FlightMap

/// Corridor Scan Complex Mission Item visuals
TransectStyleMapVisuals {
    polygonInteractive: false

    property bool _currentItem: object.isCurrentItem

    beeCopterMapPolylineVisuals {
        id:             mapPolylineVisuals
        mapControl:     map
        mapPolyline:    object.corridorPolyline
        interactive:    _currentItem && parent.interactive
        lineWidth:      3
        lineColor:      "#be781c"
        visible:        _currentItem
        opacity:        parent.opacity
    }
}
