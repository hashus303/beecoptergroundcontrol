import QtQml.Models

import beeCopter
import beeCopter.Controls
import beeCopter.FlyView

ToolStrip {
    id: _root

    signal displayPreFlightChecklist

    FlyViewToolStripActionList {
        id: flyViewToolStripActionList

        onDisplayPreFlightChecklist: _root.displayPreFlightChecklist()
    }

    model: flyViewToolStripActionList.model
}
