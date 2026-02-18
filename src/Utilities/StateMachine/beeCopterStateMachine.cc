#include "beeCopterStateMachine.h"
#include "beeCopterApplication.h"
#include "AudioOutput.h"
#include "MultiVehicleManager.h"
#include "Vehicle.h"
#include "AudioOutput.h"

#include <QFinalState>

beeCopterStateMachine::beeCopterStateMachine(const QString& machineName, Vehicle *vehicle, QObject* parent)
    : QStateMachine (parent)
    , _vehicle      (vehicle)
{
    setObjectName(machineName);

    connect(this, &beeCopterStateMachine::started, this, [this] () {
        qCDebug(beeCopterStateMachineLog) << "State machine started:" << objectName();
    });
    connect(this, &beeCopterStateMachine::stopped, this, [this] () {
        qCDebug(beeCopterStateMachineLog) << "State machine finished:" << objectName();
    });

    connect(this, &beeCopterStateMachine::stopped, this, [this] () { this->deleteLater(); });
}
