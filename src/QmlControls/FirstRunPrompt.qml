import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

import beeCopter
import beeCopter.Controls

// Base class for all first run prompt dialogs
beeCopterPopupDialog {
    buttons: Dialog.Ok

    property int  promptId
    property bool markAsShownOnClose: true

    onClosed: {
        if (markAsShownOnClose) {
            beeCopter.settingsManager.appSettings.firstRunPromptIdsMarkIdAsShown(promptId)
        }
    }
}
