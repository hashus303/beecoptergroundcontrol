#pragma once

#include <QState>
#include <QString>
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(beeCopterStateMachineLog)

class beeCopterStateMachine;
class Vehicle;

/// Base class for all beeCopter state machine states
class beeCopterState : public QState
{
    Q_OBJECT

public:
    beeCopterState(const QString& stateName, QState* parentState);

    /// Simpler version of QState::addTransition which assumes the sender is this
    template <typename PointerToMemberFunction> QSignalTransition *addThisTransition(PointerToMemberFunction signal, QAbstractState *target)
        { return QState::addTransition(this, signal, target); };

    beeCopterStateMachine* machine() const;
    Vehicle *vehicle();
    QString stateName() const;

signals:
    void advance();     ///< Signal to indicate state is complete and machine should advance to next state
    void error();       ///< Signal to indicate an error has occurred
};
