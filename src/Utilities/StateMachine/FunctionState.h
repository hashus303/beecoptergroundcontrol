#pragma once

#include "beeCopterState.h"

#include <functional>

class FunctionState : public beeCopterState
{
    Q_OBJECT

public:
    FunctionState(const QString& stateName, QState* parentState, std::function<void()>);

private:
    std::function<void()> _function;
};
