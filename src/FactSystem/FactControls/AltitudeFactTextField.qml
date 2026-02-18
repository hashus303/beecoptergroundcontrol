import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

FactTextField {
    unitsLabel:                 fact ? fact.units : ""
    extraUnitsLabel:            fact ? _altitudeModeExtraUnits : ""
    showUnits:                  true
    showHelp:                   true

    property int altitudeMode: beeCopter.AltitudeModeNone

    property string _altitudeModeExtraUnits

    onAltitudeModeChanged: updateAltitudeModeExtraUnits()

    function updateAltitudeModeExtraUnits() {
        _altitudeModeExtraUnits = beeCopter.altitudeModeExtraUnits(altitudeMode);
    }
}
