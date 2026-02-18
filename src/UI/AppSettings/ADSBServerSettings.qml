import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls

SettingsPage {
    property var    _settingsManager:           beeCopter.settingsManager
    property var     _adsbSettings:             _settingsManager.adsbVehicleManagerSettings
    property Fact   _adsbServerConnectEnabled:  _adsbSettings.adsbServerConnectEnabled

    SettingsGroupLayout {
        Layout.fillWidth:   true
        visible:            beeCopter.settingsManager.adsbVehicleManagerSettings.visible

        FactCheckBoxSlider {
            Layout.fillWidth:   true
            text:               fact.shortDescription
            fact:               _adsbServerConnectEnabled
            visible:            fact.visible
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth:   true
        visible:             _adsbSettings.adsbServerHostAddress.visible || _adsbSettings.adsbServerPort.visible
        enabled:             _adsbServerConnectEnabled.rawValue

        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              fact.shortDescription
            fact:               _adsbSettings.adsbServerHostAddress
            visible:            fact.visible
        }

        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              fact.shortDescription
            fact:               _adsbSettings.adsbServerPort
            visible:            fact.visible
        }
    }
}
