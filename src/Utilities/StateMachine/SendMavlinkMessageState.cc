#include "SendMavlinkMessageState.h"
#include "MAVLinkProtocol.h"
#include "MultiVehicleManager.h"
#include "Vehicle.h"
#include "VehicleLinkManager.h"
#include "beeCopterLoggingCategory.h"

SendMavlinkMessageState::SendMavlinkMessageState(QState *parent, MessageEncoder encoder, int retryCount)
    : beeCopterState(QStringLiteral("SendMavlinkMessageState"), parent)
    , _encoder(std::move(encoder))
    , _retryCount(retryCount)
{
    connect(this, &QState::entered, this, &SendMavlinkMessageState::_sendMessage);
}

void SendMavlinkMessageState::_sendMessage()
{
    if (++_runCount > _retryCount + 1  /* +1 for initial attempt */) {
        qCDebug(beeCopterStateMachineLog) << "Exceeded maximum retries" << stateName();
        emit error();
        return;
    }

    if (!_encoder) {
        qCDebug(beeCopterStateMachineLog) << "No MAVLink message encoder configured" << stateName();
        emit error();
        return;
    }

    SharedLinkInterfacePtr sharedLink = vehicle()->vehicleLinkManager()->primaryLink().lock();
    if (!sharedLink) {
        qCWarning(beeCopterStateMachineLog) << "No active link available to send MAVLink message" << stateName();
        emit error();
        return;
    }

    mavlink_message_t message{};

    const uint8_t systemId = MAVLinkProtocol::instance()->getSystemId();
    const uint8_t componentId [[maybe_unused]] = MAVLinkProtocol::getComponentId();
    const uint8_t channel = sharedLink->mavlinkChannel();

    _encoder(systemId, channel, &message);
    if (!vehicle()->sendMessageOnLinkThreadSafe(sharedLink.get(), message)) {
        qCWarning(beeCopterStateMachineLog) << "Failed to send MAVLink message" << stateName();
        emit error();
        return;
    }

    emit advance();
}
