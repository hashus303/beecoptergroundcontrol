import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

import beeCopter
import beeCopter.Controls

/// Popup container for preflight checklists
beeCopterPopupDialog {
    id:         _root
    title:      qsTr("Pre-Flight Checklist")
    buttons:    Dialog.Close

    property var    _activeVehicle:     beeCopter.multiVehicleManager.activeVehicle
    property bool   _useChecklist:      beeCopter.settingsManager.appSettings.useChecklist.rawValue && beeCopter.corePlugin.options.preFlightChecklistUrl.toString().length
    property bool   _enforceChecklist:  _useChecklist && beeCopter.settingsManager.appSettings.enforceChecklist.rawValue
    property bool   _checklistComplete: _activeVehicle && (_activeVehicle.checkListState === Vehicle.CheckListPassed)

    on_ActiveVehicleChanged: _showPreFlightChecklistIfNeeded()

    Connections {
        target:                             mainWindow
        onShowPreFlightChecklistIfNeeded:   _root._showPreFlightChecklistIfNeeded()
    }

    function _showPreFlightChecklistIfNeeded() {
        if (_activeVehicle && !_checklistComplete && _enforceChecklist) {
            popupTimer.restart()
        }
    }

    Timer {
        id:             popupTimer
        interval:       1000
        repeat:         false
        onTriggered: {
            if (!_checklistComplete) {
                _root.open()
            } else {
                _root.close()
            }
        }
    }

    Loader {
        id:     checkList
        source: beeCopter.corePlugin.options.preFlightChecklistUrl
    }

    property alias checkListItem: checkList.item

    Connections {
        target: checkList.item
        onAllChecksPassedChanged: {
            if (target.allChecksPassed) {
                popupTimer.restart()
            }
        }
    }
}
