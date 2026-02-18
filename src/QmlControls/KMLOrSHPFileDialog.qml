import QtQuick

import beeCopter
import beeCopter.Controls

beeCopterFileDialog {
    id:             kmlOrSHPLoadDialog
    folder:         beeCopter.settingsManager.appSettings.missionSavePath
    title:          qsTr("Select File")
    nameFilters:    ShapeFileHelper.fileDialogKMLOrSHPFilters
}
