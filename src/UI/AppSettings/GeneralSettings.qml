import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls

SettingsPage {
    property var    _settingsManager:           beeCopter.settingsManager
    property var    _appSettings:               _settingsManager.appSettings
    property var    _brandImageSettings:        _settingsManager.brandImageSettings
    property Fact   _appFontPointSize:          _appSettings.appFontPointSize
    property Fact   _userBrandImageIndoor:      _brandImageSettings.userBrandImageIndoor
    property Fact   _userBrandImageOutdoor:     _brandImageSettings.userBrandImageOutdoor
    property Fact   _appSavePath:               _appSettings.savePath

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("General")

        LabelledFactComboBox {
            label:      qsTr("Language")
            fact:       _appSettings.qLocaleLanguage
            indexModel: false
            visible:    _appSettings.qLocaleLanguage.visible
        }

        LabelledFactComboBox {
            label:      qsTr("Color Scheme")
            fact:       _appSettings.indoorPalette
            indexModel: false
            visible:    _appSettings.indoorPalette.visible
        }

        LabelledFactComboBox {
            label:       qsTr("Stream GCS Position")
            fact:       _appSettings.followTarget
            indexModel: false
            visible:    _appSettings.followTarget.visible
        }

        FactCheckBoxSlider {
            Layout.fillWidth: true
            text:           qsTr("Mute all audio output")
            fact:       _audioMuted
            visible:    _audioMuted.visible
            property Fact _audioMuted: _appSettings.audioMuted
        }

        FactCheckBoxSlider {
            Layout.fillWidth: true
            text:       fact.shortDescription
            fact:       _appSettings.androidDontSaveToSDCard
            visible:    fact.visible
        }

        beeCopterCheckBoxSlider {
            Layout.fillWidth: true
            text:       qsTr("Clear all settings on next start")
            checked:    false
            onClicked: {
                if (checked) {
                    beeCopter.deleteAllSettingsNextBoot()
                } else {
                    beeCopter.clearDeleteAllSettingsNextBoot()
                }
            }
        }

        RowLayout {
            Layout.fillWidth:   true
            spacing:            ScreenTools.defaultFontPixelWidth * 2
            visible:            _appFontPointSize.visible

            beeCopterLabel {
                Layout.fillWidth:   true
                text:               qsTr("UI Scaling")
            }

            RowLayout {
                spacing: ScreenTools.defaultFontPixelWidth * 2

                beeCopterButton {
                    Layout.preferredWidth:  height
                    height:                 baseFontEdit.height * 1.5
                    text:                   "-"
                    onClicked: {
                        if (_appFontPointSize.value > _appFontPointSize.min) {
                            _appFontPointSize.value = _appFontPointSize.value - 1
                        }
                    }
                }

                beeCopterLabel {
                    id:                     baseFontEdit
                    width:                  ScreenTools.defaultFontPixelWidth * 6
                    text:                   (beeCopter.settingsManager.appSettings.appFontPointSize.value / ScreenTools.platformFontPointSize * 100).toFixed(0) + "%"
                }

                beeCopterButton {
                    Layout.preferredWidth:  height
                    height:                 baseFontEdit.height * 1.5
                    text:                   "+"
                    onClicked: {
                        if (_appFontPointSize.value < _appFontPointSize.max) {
                            _appFontPointSize.value = _appFontPointSize.value + 1
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth:   true
            spacing:            ScreenTools.defaultFontPixelWidth * 2
            visible:            _appSavePath.visible && !ScreenTools.isMobile

            ColumnLayout {
                Layout.fillWidth:   true
                spacing:            0

                beeCopterLabel { text: qsTr("Application Load/Save Path") }
                beeCopterLabel {
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    text:               _appSavePath.rawValue === "" ? qsTr("<default location>") : _appSavePath.value
                    elide:              Text.ElideMiddle
                }
            }

            beeCopterButton {
                text:       qsTr("Browse")
                onClicked:  savePathBrowseDialog.openForLoad()
                beeCopterFileDialog {
                    id:                 savePathBrowseDialog
                    title:              qsTr("Choose the location to save/load files")
                    folder:             _appSavePath.rawValue
                    selectFolder:       true
                    onAcceptedForLoad:  (file) => _appSavePath.rawValue = file
                }
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("Units")
        visible:            beeCopter.settingsManager.unitsSettings.visible

        Repeater {
            model: [ beeCopter.settingsManager.unitsSettings.horizontalDistanceUnits, beeCopter.settingsManager.unitsSettings.verticalDistanceUnits, beeCopter.settingsManager.unitsSettings.areaUnits, beeCopter.settingsManager.unitsSettings.speedUnits, beeCopter.settingsManager.unitsSettings.temperatureUnits ]

            LabelledFactComboBox {
                label:                  modelData.shortDescription
                fact:                   modelData
                indexModel:             false
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("Brand Image")
        visible:            _brandImageSettings.visible && !ScreenTools.isMobile

        RowLayout {
            Layout.fillWidth:   true
            spacing:            ScreenTools.defaultFontPixelWidth * 2
            visible:            _userBrandImageIndoor.visible

            ColumnLayout {
                Layout.fillWidth:   true
                spacing:            0

                beeCopterLabel {
                    Layout.fillWidth:   true
                    text:               qsTr("Indoor Image")
                }
                beeCopterLabel {
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    text:               _userBrandImageIndoor.valueString.replace("file:///", "")
                    elide:              Text.ElideMiddle
                    visible:            _userBrandImageIndoor.valueString.length > 0
                }
            }

            beeCopterButton {
                text:       qsTr("Browse")
                onClicked:  userBrandImageIndoorBrowseDialog.openForLoad()

                beeCopterFileDialog {
                    id:                 userBrandImageIndoorBrowseDialog
                    title:              qsTr("Choose custom brand image file")
                    folder:             _userBrandImageIndoor.rawValue.replace("file:///", "")
                    selectFolder:       false
                    onAcceptedForLoad:  (file) => _userBrandImageIndoor.rawValue = "file:///" + file
                }
            }
        }

        RowLayout {
            Layout.fillWidth:   true
            spacing:            ScreenTools.defaultFontPixelWidth * 2
            visible:            _userBrandImageOutdoor.visible

            ColumnLayout {
                Layout.fillWidth:   true
                spacing:            0

                beeCopterLabel {
                    Layout.fillWidth:   true
                    text:               qsTr("Outdoor Image")
                }
                beeCopterLabel {
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    text:               _userBrandImageOutdoor.valueString.replace("file:///", "")
                    elide:              Text.ElideMiddle
                    visible:            _userBrandImageOutdoor.valueString.length > 0
                }
            }

            beeCopterButton {
                text:       qsTr("Browse")
                onClicked:  userBrandImageOutdoorBrowseDialog.openForLoad()

                beeCopterFileDialog {
                    id:                 userBrandImageOutdoorBrowseDialog
                    title:              qsTr("Choose custom brand image file")
                    folder:             _userBrandImageOutdoor.rawValue.replace("file:///", "")
                    selectFolder:       false
                    onAcceptedForLoad:  (file) => _userBrandImageOutdoor.rawValue = "file:///" + file
                }
            }
        }

        LabelledButton {
            label:      qsTr("Reset Images")
            buttonText: qsTr("Reset")
            onClicked:  {
                _userBrandImageIndoor.rawValue = ""
                _userBrandImageOutdoor.rawValue = ""
            }
        }
    }
}
