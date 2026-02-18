#pragma once

#include "beeCopterState.h"

#include <QString>

/// Display an application message to the user

class ShowAppMessageState : public beeCopterState
{
    Q_OBJECT

public:
    ShowAppMessageState(QState* parentState, const QString& appMessage);

private:
    QString _appMessage;
};
