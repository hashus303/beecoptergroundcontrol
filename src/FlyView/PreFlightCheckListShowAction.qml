import beeCopter
import beeCopter.Controls

ToolStripAction {
    text:           qsTr("Checklist")
    iconSource:     "/qmlimages/check.svg"
    visible:        _useChecklist
    enabled:        _useChecklist && _activeVehicle && !_activeVehicle.armed

    property var  _activeVehicle:   beeCopter.multiVehicleManager.activeVehicle
    property bool _useChecklist:    beeCopter.settingsManager.appSettings.useChecklist.rawValue && beeCopter.corePlugin.options.preFlightChecklistUrl.toString().length
}
