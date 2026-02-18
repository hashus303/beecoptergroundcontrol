import beeCopter
import beeCopter.FlyView

GuidedToolStripAction {
    text:       _guidedController.rtlTitle
    iconSource: "/res/rtl.svg"
    visible:    true
    enabled:    _guidedController.showRTL
    actionID:   _guidedController.actionRTL
}
