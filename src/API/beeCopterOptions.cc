#include "beeCopterOptions.h"
#include "beeCopterLoggingCategory.h"

beeCopter_LOGGING_CATEGORY(beeCopterFlyViewOptionsLog, "API.beeCopterFlyViewOptions");

beeCopterFlyViewOptions::beeCopterFlyViewOptions(beeCopterOptions *options, QObject *parent)
    : QObject(parent)
    , _options(options)
{
    // qCDebug(beeCopterFlyViewOptionsLog) << Q_FUNC_INFO << this;
}

beeCopterFlyViewOptions::~beeCopterFlyViewOptions()
{
    // qCDebug(beeCopterFlyViewOptionsLog) << Q_FUNC_INFO << this;
}

/*===========================================================================*/

beeCopter_LOGGING_CATEGORY(beeCopterOptionsLog, "API.beeCopterOptions");

beeCopterOptions::beeCopterOptions(QObject *parent)
    : QObject(parent)
    , _defaultFlyViewOptions(new beeCopterFlyViewOptions(this))
{
    // qCDebug(beeCopterOptionsLog) << Q_FUNC_INFO << this;
}

beeCopterOptions::~beeCopterOptions()
{
    // qCDebug(beeCopterOptionsLog) << Q_FUNC_INFO << this;
}
