import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FlyView

RowLayout {
    TelemetryValuesBar {
        Layout.alignment:       Qt.AlignBottom
        extraWidth:             instrumentPanel.extraValuesWidth
        settingsGroup:          factValueGrid.telemetryBarSettingsGroup
        specificVehicleForCard: null // Tracks active vehicle
    }

    FlyViewInstrumentPanel {
        id:                 instrumentPanel
        Layout.alignment:   Qt.AlignBottom
        visible:            beeCopter.corePlugin.options.flyView.showInstrumentPanel && _showSingleVehicleUI
    }
}
