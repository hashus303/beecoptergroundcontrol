import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

//-------------------------------------------------------------------------
//-- Armed Indicator
beeCopterComboBox {
    anchors.verticalCenter: parent.verticalCenter
    alternateText:          _armed ? qsTr("Armed") : qsTr("Disarmed")
    model:                  [ qsTr("Arm"), qsTr("Disarm") ]
    font.pointSize:         ScreenTools.mediumFontPointSize
    currentIndex:           -1
    sizeToContents:         true

    property bool showIndicator: true

    property var    _activeVehicle: beeCopter.multiVehicleManager.activeVehicle
    property bool   _armed:         _activeVehicle ? _activeVehicle.armed : false

    onActivated: (index) => {
        if (index == 0) {
            mainWindow.armVehicleRequest()
        } else {
            mainWindow.disarmVehicleRequest()
        }
        currentIndex = -1
    }
}
