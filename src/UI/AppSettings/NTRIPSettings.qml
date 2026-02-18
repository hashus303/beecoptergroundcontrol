import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import beeCopter
import beeCopter.FactControls
import beeCopter.Controls
import beeCopter.NTRIP 1.0

SettingsPage {
    property var _settingsManager:   beeCopter.settingsManager
    property var _ntrip:             _settingsManager.ntripSettings
    property Fact _enabled:          _ntrip.ntripServerConnectEnabled

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("NTRIP / RTK")
        visible:            _ntrip.visible

        FactCheckBoxSlider {
            Layout.fillWidth:   true
            text:               _enabled.shortDescription
            fact:               _enabled
            visible:            _enabled.visible
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth:   true
        visible:            _ntrip.ntripServerHostAddress.visible || _ntrip.ntripServerPort.visible ||
                            _ntrip.ntripUsername.visible || _ntrip.ntripPassword.visible ||
                            _ntrip.ntripMountpoint.visible || _ntrip.ntripWhitelist.visible ||
                            _ntrip.ntripUseSpartn.visible
        enabled:            _enabled.rawValue

        // Status line
        beeCopterLabel {
            Layout.fillWidth:   true
            Layout.minimumHeight: 30
            visible: true
            text: {
                try {
                    return NTRIPManager ? (NTRIPManager.ntripStatus || "Disconnected") : "NTRIP Manager not available"
                } catch (e) {
                    return "Disconnected"
                }
            }
            wrapMode: Text.WordWrap
            color: {
                try {
                    if (!NTRIPManager) return beeCopterPal.text
                    var status = NTRIPManager.ntripStatus || ""
                    if (status.toLowerCase().includes("connected")) return beeCopterPal.colorGreen
                    if (status.toLowerCase().includes("connecting")) return beeCopterPal.colorOrange
                    if (status.toLowerCase().includes("error") || status.toLowerCase().includes("failed")) return beeCopterPal.colorRed
                    return beeCopterPal.text
                } catch (e) {
                    return beeCopterPal.text
                }
            }
        }

        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              _ntrip.ntripServerHostAddress.shortDescription
            fact:               _ntrip.ntripServerHostAddress
            visible:            _ntrip.ntripServerHostAddress.visible
            textFieldPreferredWidth: ScreenTools.defaultFontPixelWidth * 60
        }

        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              _ntrip.ntripServerPort.shortDescription
            fact:               _ntrip.ntripServerPort
            visible:            _ntrip.ntripServerPort.visible
            textFieldPreferredWidth: ScreenTools.defaultFontPixelWidth * 20
        }

        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              _ntrip.ntripUsername.shortDescription
            fact:               _ntrip.ntripUsername
            visible:            _ntrip.ntripUsername.visible
            textFieldPreferredWidth: ScreenTools.defaultFontPixelWidth * 60
        }

        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              _ntrip.ntripPassword.shortDescription
            fact:               _ntrip.ntripPassword
            visible:            _ntrip.ntripPassword.visible
            textField.echoMode: TextInput.Password
            textFieldPreferredWidth: ScreenTools.defaultFontPixelWidth * 60
        }

        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              _ntrip.ntripMountpoint.shortDescription
            fact:               _ntrip.ntripMountpoint
            visible:            _ntrip.ntripMountpoint.visible
            textFieldPreferredWidth: ScreenTools.defaultFontPixelWidth * 40
        }

        LabelledFactTextField {
            Layout.fillWidth:   true
            label:              _ntrip.ntripWhitelist.shortDescription
            fact:               _ntrip.ntripWhitelist
            visible:            _ntrip.ntripWhitelist.visible
            textFieldPreferredWidth: ScreenTools.defaultFontPixelWidth * 40
        }

        FactCheckBoxSlider {
            Layout.fillWidth:   true
            text:               _ntrip.ntripUseSpartn.shortDescription
            fact:               _ntrip.ntripUseSpartn
            visible:            _ntrip.ntripUseSpartn.visible
            enabled:            false
        }
    }
}
