import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

RowLayout {
    property var fact: Fact { }

    beeCopterLabel {
        text: fact.name + ":"
    }

    FactTextField {
        Layout.fillWidth:   true
        showUnits:          true
        fact:               parent.fact
    }
}
