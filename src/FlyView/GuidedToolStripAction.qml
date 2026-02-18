import beeCopter
import beeCopter.Controls

ToolStripAction {
    property int    actionID
    property string message

    property var _guidedController: globals.guidedControllerFlyView

    onTriggered: {
        _guidedController.closeAll()
        _guidedController.confirmAction(actionID)
    }
}
