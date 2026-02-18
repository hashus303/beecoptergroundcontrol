#include "FunctionState.h"

#include <QTimer>

/// Executes a function when the state is entered
FunctionState::FunctionState(const QString& stateName, QState* parentState, std::function<void()> function)
    : beeCopterState   (stateName, parentState)
    , _function     (function)
{
    connect(this, &QState::entered, this, [this] () {
        _function();
        emit advance();
    });
}
