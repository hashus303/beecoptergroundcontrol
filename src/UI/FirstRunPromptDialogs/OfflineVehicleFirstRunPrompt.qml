import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls

FirstRunPrompt {
    title:      qsTr("Vehicle Information")
    promptId:   beeCopter.corePlugin.offlineVehicleFirstRunPromptId

    property real   _margins:               ScreenTools.defaultFontPixelWidth
    property var    _appSettings:           beeCopter.settingsManager.appSettings
    property bool   _multipleFirmware:      !beeCopter.singleFirmwareSupport
    property bool   _multipleVehicleTypes:  !beeCopter.singleVehicleSupport
    property real   _fieldWidth:            ScreenTools.defaultFontPixelWidth * 16

    ColumnLayout {
        spacing: ScreenTools.defaultFontPixelHeight

        beeCopterLabel {
            id:                     unitsSectionLabel
            Layout.preferredWidth:  valueRect.width
            text:                   qsTr("Specify information about the vehicle you plan to fly. If you are unsure of the correct values leave them as is.")
            wrapMode:               Text.WordWrap
        }

        Rectangle {
            id:                     valueRect
            Layout.preferredHeight: valueGrid.height + (_margins * 2)
            Layout.preferredWidth:  valueGrid.width + (_margins * 2)
            color:                  beeCopterPal.windowShade
            Layout.fillWidth:       true

            GridLayout {
                id:                 valueGrid
                anchors.margins:    _margins
                anchors.top:        parent.top
                anchors.left:       parent.left
                columns:            2

                beeCopterLabel {
                    Layout.fillWidth:   true
                    text:               qsTr("Firmware")
                    visible:            _multipleFirmware
                }
                FactComboBox {
                    Layout.preferredWidth:  _fieldWidth
                    fact:                   beeCopter.settingsManager.appSettings.offlineEditingFirmwareClass
                    indexModel:             false
                    visible:                _multipleFirmware
                }

                beeCopterLabel {
                    Layout.fillWidth:   true
                    text:               qsTr("Vehicle")
                    visible:            _multipleVehicleTypes
                }
                FactComboBox {
                    Layout.preferredWidth:  _fieldWidth
                    fact:                   beeCopter.settingsManager.appSettings.offlineEditingVehicleClass
                    indexModel:             false
                    visible:                _multipleVehicleTypes
                }
            }
        }
    }
}
