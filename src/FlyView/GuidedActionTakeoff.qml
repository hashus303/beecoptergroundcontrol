import beeCopter
import beeCopter.FlyView

GuidedToolStripAction {
    text:       _guidedController.takeoffTitle
    iconSource: "/res/takeoff.svg"
    visible:    _guidedController.showTakeoff || !_guidedController.showLand
    enabled:    _guidedController.showTakeoff
    actionID:   _guidedController.actionTakeoff
}
