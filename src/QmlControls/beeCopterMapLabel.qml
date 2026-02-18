import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

/// Text control used for displaying text of Maps
beeCopterLabel {
    property var map

    beeCopterMapPalette { id: mapPal; lightColors: map.isSatelliteMap }

    color:      mapPal.text
    style:      Text.Outline
    styleColor: mapPal.textOutline
}
