import QtQuick

import beeCopter
import beeCopter.Controls

SelectableControl {
    z:                      beeCopter.zOrderWidgets
    selectionUIRightAnchor: true
    selectedControl:        beeCopter.settingsManager.flyViewSettings.instrumentQmlFile2

    property var  missionController:    _missionController
    property real extraInset:           innerControl.extraInset
    property real extraValuesWidth:     innerControl.extraValuesWidth
}
