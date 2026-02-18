#include "ShowAppMessageState.h"
#include "beeCopterApplication.h"

ShowAppMessageState::ShowAppMessageState(QState* parentState, const QString& appMessage)
    : beeCopterState("ShowAppMessageState", parentState)
    , _appMessage(appMessage)
{
    connect(this, &QState::entered, this, [this] () {
        qCDebug(beeCopterStateMachineLog) << _appMessage << stateName();
        beeCopterApp()->showAppMessage(_appMessage);
        emit advance();
    });
}
