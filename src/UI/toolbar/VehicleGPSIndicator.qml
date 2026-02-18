import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

GPSIndicator {
    property bool showIndicator: _activeVehicle.gps.telemetryAvailable

    property var _activeVehicle: beeCopter.multiVehicleManager.activeVehicle
}
