#include "beeCopterStateMachine.h"
#include "beeCopterLoggingCategory.h"

beeCopter_LOGGING_CATEGORY(beeCopterStateMachineLog, "Utilities.beeCopterStateMachine")

beeCopterState::beeCopterState(const QString& stateName, QState* parentState)
    : QState(QState::ExclusiveStates, parentState)
{
    setObjectName(stateName);

    connect(this, &QState::entered, this, [this] () {
        qCDebug(beeCopterStateMachineLog) << "Entered" << this->stateName();
    });
    connect(this, &QState::exited, this, [this] () {
        qCDebug(beeCopterStateMachineLog) << "Exited" << this->stateName();
    });
}

beeCopterStateMachine* beeCopterState::machine() const
{
    return qobject_cast<beeCopterStateMachine*>(QState::machine());
}

Vehicle *beeCopterState::vehicle()
{
    return machine()->vehicle();
}

QString beeCopterState::stateName() const
{
    if (machine()) {
        return QStringLiteral("%1:%2").arg(objectName(), machine()->machineName());
    } else {
        return objectName();
    }
}
