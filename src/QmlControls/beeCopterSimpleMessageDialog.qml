import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

beeCopterPopupDialog {
    property alias  text:           label.text
    property var    acceptFunction: null        // Mainly used by MainRootWindow.showMessage to specify accept function in call
    property var    closeFunction:  null

    onAccepted: {
        if (acceptFunction) {
            acceptFunction()
        }
    }

    onClosed: {
        if (closeFunction) {
            closeFunction()
        }
    }

    ColumnLayout {
        beeCopterLabel {
            id:                     label
            Layout.preferredWidth:  Math.max(mainWindow.width / (ScreenTools.isMobile ? 2 : 3), headerMinWidth)
            wrapMode:               Text.WordWrap
        }
    }
}
