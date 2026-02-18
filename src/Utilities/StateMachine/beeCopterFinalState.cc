#include "beeCopterFinalState.h"
#include "beeCopterState.h"
#include "beeCopterStateMachine.h"

beeCopterFinalState::beeCopterFinalState(QState* parent)
    : QFinalState(parent)
{
    connect(this, &QFinalState::entered, this, [this] () {
        qCDebug(beeCopterStateMachineLog) << "Entered Final State" << qobject_cast<beeCopterStateMachine*>(this->machine())->machineName();
    });
    connect(this, &QState::exited, this, [this] () {
        qCDebug(beeCopterStateMachineLog) << "Exited Final State" << qobject_cast<beeCopterStateMachine*>(this->machine())->machineName();
    });
}
