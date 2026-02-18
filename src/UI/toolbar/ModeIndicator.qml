import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

//-------------------------------------------------------------------------
//-- Mode Indicator
beeCopterComboBox {
    anchors.verticalCenter: parent.verticalCenter
    alternateText:          _activeVehicle ? _activeVehicle.flightMode : ""
    model:                  _flightModes
    font.pointSize:         ScreenTools.mediumFontPointSize
    currentIndex:           -1
    sizeToContents:         true

    property bool showIndicator: true

    property var _activeVehicle:    beeCopter.multiVehicleManager.activeVehicle
    property var _flightModes:      _activeVehicle ? _activeVehicle.flightModes : [ ]

    onActivated: (index) => {
        _activeVehicle.flightMode = _flightModes[index]
        currentIndex = -1
    }
}
