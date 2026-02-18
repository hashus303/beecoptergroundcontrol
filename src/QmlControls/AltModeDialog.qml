import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

beeCopterPopupDialog {
    title:   qsTr("Altitude Mode")
    buttons: Dialog.Close

    property var rgRemoveModes
    property var updateAltModeFn
    property var currentAltMode

    Component.onCompleted: {
        // Check for custom build override on AMSL usage
        if (!beeCopter.corePlugin.options.showMissionAbsoluteAltitude && currentAltMode != beeCopter.AltitudeModeAbsolute) {
            rgRemoveModes.push(beeCopter.AltitudeModeAbsolute)
        }

        // Remove modes specified by consumer
        for (var i=0; i<rgRemoveModes.length; i++) {
            for (var j=0; j<buttonModel.count; j++) {
                if (buttonModel.get(j).modeValue == rgRemoveModes[i]) {
                    buttonModel.remove(j)
                    break
                }
            }
        }

        buttonRepeater.model = buttonModel
    }

    ListModel {
        id: buttonModel

        ListElement {
            modeName:   qsTr("Relative")
            help:       qsTr("Altitude above home position")
            modeValue:  beeCopter.AltitudeModeRelative
        }
        ListElement {
            modeName:   qsTr("Absolute")
            help:       qsTr("Altitude above mean sea level (AMSL)")
            modeValue:  beeCopter.AltitudeModeAbsolute
        }
        ListElement {
            modeName:   qsTr("Terrain")
            help:       qsTr("Altitude above terrain at waypoint")
            modeValue:  beeCopter.AltitudeModeTerrainFrame
        }
        ListElement {
            modeName:   qsTr("Terrain Calculated")
            help:       qsTr("Altitudes are terrain-relative; converting to AMSL before upload")
            modeValue:  beeCopter.AltitudeModeCalcAboveTerrain
        }
        ListElement {
            modeName:   qsTr("Waypoint Defined")
            help:       qsTr("Each waypoint specifies its own altitude mode")
            modeValue:  beeCopter.AltitudeModeMixed
        }
    }

    Column {
        spacing: ScreenTools.defaultFontPixelWidth

        beeCopterLabel {
            text: qsTr("Altitude mode for mission items")
            font.pointSize: ScreenTools.smallFontPointSize
        }

        Repeater {
            id: buttonRepeater

            Button {
                hoverEnabled:   true
                checked:        modeValue == currentAltMode

                background: Rectangle {
                    radius: ScreenTools.defaultFontPixelHeight / 2
                    color:  pressed | hovered | checked ? beeCopter.globalPalette.buttonHighlight: beeCopter.globalPalette.button
                }

                contentItem: Column {
                    spacing: 0

                    beeCopterLabel {
                        id:     modeNameLabel
                        text:   modeName
                        color:  pressed | hovered | checked ? beeCopter.globalPalette.buttonHighlightText: beeCopter.globalPalette.buttonText
                    }

                    beeCopterLabel {
                        width:              ScreenTools.defaultFontPixelWidth * 40
                        text:               help
                        wrapMode:           Label.WordWrap
                        font.pointSize:     ScreenTools.smallFontPointSize
                        color:              modeNameLabel.color
                    }
                }

                onClicked: {
                    updateAltModeFn(modeValue)
                    close()
                }
            }
        }
    }
}
