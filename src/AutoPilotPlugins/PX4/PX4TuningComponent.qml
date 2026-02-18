import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

ColumnLayout {
    id:         root
    spacing:    ScreenTools.defaultFontPixelWidth / 4

    property var model

    property real _availableHeight: availableHeight
    property real _availableWidth:  availableWidth

    FactPanelController {
        id:         controller
    }

    beeCopterTabBar {
        id: tabBar

        Repeater {
            model: root.model
            beeCopterTabButton {
                text: buttonText
            }
        }
    }

    Loader {
        id:     loader
        source: model.get(tabBar.currentIndex).tuningPage

        property bool useAutoTuning:    true
        property real availableWidth:   _availableWidth
        property real availableHeight:  _availableHeight - loader.y
    }
}
