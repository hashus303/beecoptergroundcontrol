#include "PX4FirmwarePluginFactory.h"
#include "PX4FirmwarePlugin.h"

PX4FirmwarePluginFactory PX4FirmwarePluginFactory;

PX4FirmwarePluginFactory::PX4FirmwarePluginFactory(void)
    : _pluginInstance(nullptr)
{

}

QList<beeCopterMAVLink::FirmwareClass_t> PX4FirmwarePluginFactory::supportedFirmwareClasses(void) const
{
    QList<beeCopterMAVLink::FirmwareClass_t> list;
    list.append(beeCopterMAVLink::FirmwareClassPX4);
    return list;
}

FirmwarePlugin* PX4FirmwarePluginFactory::firmwarePluginForAutopilot(MAV_AUTOPILOT autopilotType, MAV_TYPE /*vehicleType*/)
{
    if (autopilotType == MAV_AUTOPILOT_PX4) {
        if (!_pluginInstance) {
            _pluginInstance = new PX4FirmwarePlugin();
        }
        return _pluginInstance;
    }
    return nullptr;
}
