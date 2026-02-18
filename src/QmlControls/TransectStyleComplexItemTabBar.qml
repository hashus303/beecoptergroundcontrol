import QtQuick

import beeCopter
import beeCopter.Controls

beeCopterTabBar {
    id: tabBar

    Component.onCompleted: currentIndex = beeCopter.settingsManager.planViewSettings.displayPresetsTabFirst.rawValue ? 2 : 0

    beeCopterTabButton { icon.source: "/qmlimages/PatternGrid.png"; icon.height: ScreenTools.defaultFontPixelHeight }
    beeCopterTabButton { icon.source: "/qmlimages/PatternCamera.png"; icon.height: ScreenTools.defaultFontPixelHeight }
    beeCopterTabButton { icon.source: "/qmlimages/PatternTerrain.png"; icon.height: ScreenTools.defaultFontPixelHeight }
    beeCopterTabButton { icon.source: "/qmlimages/PatternPresets.png"; icon.height: ScreenTools.defaultFontPixelHeight }
}
