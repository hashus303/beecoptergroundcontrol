import QtQuick

import beeCopter
import beeCopter.Controls
import beeCopter.AutoPilotPlugins.PX4

SetupPage {
    pageComponent:  pageComponent
    Component {
        id: pageComponent
        SensorsSetup {
            width:      availableWidth
            height:     availableHeight
        }
    }
}
