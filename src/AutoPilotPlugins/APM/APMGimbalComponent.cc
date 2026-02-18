#include "APMGimbalComponent.h"
#include "Vehicle.h"

APMGimbalComponent::APMGimbalComponent(Vehicle *vehicle, AutoPilotPlugin *autopilot, QObject *parent)
    : VehicleComponent(vehicle, autopilot, AutoPilotPlugin::UnknownVehicleComponent, parent)
{

}

QUrl APMGimbalComponent::setupSource() const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/beeCopter/AutoPilotPlugins/APM/APMGimbalComponent.qml"));
}
