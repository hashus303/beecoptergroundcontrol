import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

ColumnLayout {
    property var additionalActions
    property var mavlinkActions
    property var customActions

    property var  _activeVehicle:       beeCopter.multiVehicleManager.activeVehicle
    property var  _guidedController:    globals.guidedControllerFlyView

    // Pre-defined Additional Guided Actions
    Repeater {
        model: additionalActions.model

        beeCopterButton {
            Layout.fillWidth:   true
            text:               modelData.title
            visible:            modelData.visible

            onClicked: {
                dropPanel.hide()
                _guidedController.confirmAction(modelData.action)
            }
        }
    }

    // Custom Build Actions
    Repeater {
        model: customActions.model

        beeCopterButton {
            Layout.fillWidth:   true
            text:               modelData.title
            visible:            modelData.visible

            onClicked: {
                dropPanel.hide()
                _guidedController.confirmAction(modelData.action)
            }
        }
    }

    // User-defined Mavlink Actions
    Repeater {
        model: _activeVehicle ? mavlinkActions : undefined // The action list is a QmlObjectListModel

        beeCopterButton {
            Layout.fillWidth:   true
            text:               object.label

            onClicked: {
                dropPanel.hide()
                object.sendTo(_activeVehicle)
            }
        }
    }
}
