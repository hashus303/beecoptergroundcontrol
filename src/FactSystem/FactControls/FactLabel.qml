import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

beeCopterLabel {
    property bool showUnits:    true
    property Fact fact:         Fact { }

    text: fact.valueString + (showUnits ? " " + fact.units : "")
}
