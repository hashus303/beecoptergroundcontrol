#pragma once

#include <QFinalState>

/// Final state for a beeCopterStateMachine
///     Same as QFinalState but with logging
class beeCopterFinalState : public QFinalState
{
    Q_OBJECT

public:
    beeCopterFinalState(QState* parent = nullptr);
};
