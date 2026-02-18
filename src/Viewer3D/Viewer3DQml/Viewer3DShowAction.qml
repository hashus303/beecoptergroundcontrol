import beeCopter
import beeCopter.Controls

ToolStripAction {
    id: root

    property bool _is3DViewOpen: beeCopterViewer3DManager.displayMode === beeCopterViewer3DManager.View3D
    property bool _viewer3DEnabled: beeCopter.settingsManager.viewer3DSettings.enabled.rawValue

    iconSource: _is3DViewOpen ? "/qmlimages/PaperPlane.svg" : "/qml/beeCopter/Viewer3D/City3DMapIcon.svg"
    text: _is3DViewOpen ? qsTr("Fly") : qsTr("3D View")
    visible: _viewer3DEnabled

    onTriggered: {
        if (_is3DViewOpen) {
            beeCopterViewer3DManager.setDisplayMode(beeCopterViewer3DManager.Map);
        } else {
            beeCopterViewer3DManager.setDisplayMode(beeCopterViewer3DManager.View3D);
        }
    }
}
