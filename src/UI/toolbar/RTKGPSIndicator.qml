import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

GPSIndicator {
    property bool showIndicator: !_activeVehicle && _rtkConnected

    property var    _activeVehicle: beeCopter.multiVehicleManager.activeVehicle
    property bool   _rtkConnected:  beeCopter.gpsRtk.connected.value
}
