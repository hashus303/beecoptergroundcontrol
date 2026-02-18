#include "MissionCommandTree.h"
#include "FirmwarePlugin.h"
#include "FirmwarePluginManager.h"
#include "MissionCommandList.h"
#include "MissionCommandUIInfo.h"
#include "beeCopterLoggingCategory.h"
#include "Vehicle.h"

#include <QtCore/QApplicationStatic>

beeCopter_LOGGING_CATEGORY(MissionCommandTreeLog, "Plan.MissionCommandTree");

Q_APPLICATION_STATIC(MissionCommandTree, _missionCommandTreeInstance);

MissionCommandTree::MissionCommandTree(bool unitTest, QObject *parent)
    : QObject(parent)
{
    qCDebug(MissionCommandTreeLog) << this;

    if (unitTest) {
        // Load unit testing tree
        _staticCommandTree[MAV_AUTOPILOT_GENERIC][beeCopterMAVLink::VehicleClassGeneric] = new MissionCommandList(":/unittest/UT-MavCmdInfoCommon.json", true, this);
        _staticCommandTree[MAV_AUTOPILOT_GENERIC][beeCopterMAVLink::VehicleClassFixedWing] = new MissionCommandList(":/unittest/UT-MavCmdInfoFixedWing.json", false, this);
        _staticCommandTree[MAV_AUTOPILOT_GENERIC][beeCopterMAVLink::VehicleClassMultiRotor] = new MissionCommandList(":/unittest/UT-MavCmdInfoMultiRotor.json", false, this);
        _staticCommandTree[MAV_AUTOPILOT_GENERIC][beeCopterMAVLink::VehicleClassVTOL] = new MissionCommandList(":/unittest/UT-MavCmdInfoVTOL.json", false, this);
        _staticCommandTree[MAV_AUTOPILOT_GENERIC][beeCopterMAVLink::VehicleClassSub] = new MissionCommandList(":/unittest/UT-MavCmdInfoSub.json", false, this);
        _staticCommandTree[MAV_AUTOPILOT_GENERIC][beeCopterMAVLink::VehicleClassRoverBoat] = new MissionCommandList(":/unittest/UT-MavCmdInfoRover.json", false, this);
    } else {
        // Load all levels of hierarchy
        for (const beeCopterMAVLink::FirmwareClass_t firmwareClass: FirmwarePluginManager::instance()->supportedFirmwareClasses()) {
            const FirmwarePlugin *const plugin = FirmwarePluginManager::instance()->firmwarePluginForAutopilot(beeCopterMAVLink::firmwareClassToAutopilot(firmwareClass), MAV_TYPE_QUADROTOR);
            for (const beeCopterMAVLink::VehicleClass_t vehicleClass: beeCopterMAVLink::allVehicleClasses()) {
                const QString overrideFile = plugin->missionCommandOverrides(vehicleClass);
                if (!overrideFile.isEmpty()) {
                    const bool baseCommandList = ((firmwareClass == beeCopterMAVLink::FirmwareClassGeneric) && (vehicleClass == beeCopterMAVLink::VehicleClassGeneric));
                    _staticCommandTree[firmwareClass][vehicleClass] = new MissionCommandList(overrideFile, baseCommandList, this);
                }
            }
        }
    }
}

MissionCommandTree::~MissionCommandTree()
{
    qCDebug(MissionCommandTreeLog) << this;
}

MissionCommandTree *MissionCommandTree::instance()
{
    return _missionCommandTreeInstance();
}

void MissionCommandTree::_collapseHierarchy(const MissionCommandList *cmdList, QMap<MAV_CMD, MissionCommandUIInfo*> &collapsedTree) const
{
    if (!cmdList) {
        return;
    }

    for (const MAV_CMD command: cmdList->commandIds()) {
        MissionCommandUIInfo *const uiInfo = cmdList->getUIInfo(command);
        if (uiInfo) {
            if (collapsedTree.contains(command)) {
                collapsedTree[command]->_overrideInfo(uiInfo);
            } else {
                collapsedTree[command] = new MissionCommandUIInfo(*uiInfo);
            }
        }
    }
}

void MissionCommandTree::_buildAllCommands(Vehicle *vehicle, beeCopterMAVLink::VehicleClass_t vtolMode)
{
    beeCopterMAVLink::FirmwareClass_t firmwareClass;
    beeCopterMAVLink::VehicleClass_t  vehicleClass;

    _firmwareAndVehicleClassInfo(vehicle, vtolMode, firmwareClass, vehicleClass);

    if (_allCommands.contains(firmwareClass) && _allCommands[firmwareClass].contains(vehicleClass)) {
        // Already built
        return;
    }

    QMap<MAV_CMD, MissionCommandUIInfo*> &collapsedTree = _allCommands[firmwareClass][vehicleClass];

    // Base of the tree is all commands
    _collapseHierarchy(_staticCommandTree[MAV_AUTOPILOT_GENERIC][beeCopterMAVLink::VehicleClassGeneric], collapsedTree);

    // Add the overrides for specific vehicle types
    if (vehicleClass != beeCopterMAVLink::VehicleClassGeneric) {
        _collapseHierarchy(_staticCommandTree[beeCopterMAVLink::FirmwareClassGeneric][vehicleClass], collapsedTree);
    }

    // Add the overrides for specific firmware class, all vehicles
    if (firmwareClass != beeCopterMAVLink::FirmwareClassGeneric) {
        _collapseHierarchy(_staticCommandTree[firmwareClass][beeCopterMAVLink::VehicleClassGeneric], collapsedTree);

        // Add overrides for specific vehicle class
        if (vehicleClass != beeCopterMAVLink::VehicleClassGeneric) {
            _collapseHierarchy(_staticCommandTree[firmwareClass][vehicleClass], collapsedTree);
        }
    }

    // Build category list from supported commands
    QList<MAV_CMD> supportedCommands = vehicle->firmwarePlugin()->supportedMissionCommands(vehicleClass);
    for (const MAV_CMD cmd: collapsedTree.keys()) {
        if (supportedCommands.contains(cmd)) {
            const QString newCategory = collapsedTree[cmd]->category();
            if (!_supportedCategories[firmwareClass][vehicleClass].contains(newCategory)) {
                _supportedCategories[firmwareClass][vehicleClass].append(newCategory);
            }
        }
    }

    _supportedCategories[firmwareClass][vehicleClass].append(_allCommandsCategory);
}

QStringList MissionCommandTree::_availableCategoriesForVehicle(Vehicle *vehicle)
{
    beeCopterMAVLink::FirmwareClass_t firmwareClass;
    beeCopterMAVLink::VehicleClass_t  vehicleClass;

    _firmwareAndVehicleClassInfo(vehicle, beeCopterMAVLink::VehicleClassGeneric, firmwareClass, vehicleClass);
    _buildAllCommands(vehicle, beeCopterMAVLink::VehicleClassGeneric);

    return _supportedCategories[firmwareClass][vehicleClass];
}

QString MissionCommandTree::friendlyName(MAV_CMD command) const
{
    const MissionCommandList *const commandList = _staticCommandTree[beeCopterMAVLink::FirmwareClassGeneric][beeCopterMAVLink::VehicleClassGeneric];
    const MissionCommandUIInfo *const uiInfo = commandList->getUIInfo(command);

    return uiInfo ? uiInfo->friendlyName() : QStringLiteral("MAV_CMD(%1)").arg(static_cast<int>(command));
}

QString MissionCommandTree::rawName(MAV_CMD command) const
{
    const MissionCommandList *const commandList = _staticCommandTree[beeCopterMAVLink::FirmwareClassGeneric][beeCopterMAVLink::VehicleClassGeneric];
    const MissionCommandUIInfo *const uiInfo = commandList->getUIInfo(command);

    return uiInfo ? uiInfo->rawName() : QStringLiteral("MAV_CMD(%1)").arg(static_cast<int>(command));
}

bool MissionCommandTree::isLandCommand(MAV_CMD command) const
{
    const MissionCommandList *const commandList = _staticCommandTree[beeCopterMAVLink::FirmwareClassGeneric][beeCopterMAVLink::VehicleClassGeneric];
    const MissionCommandUIInfo *const uiInfo = commandList->getUIInfo(command);

    return (uiInfo && uiInfo->isLandCommand());
}

bool MissionCommandTree::isTakeoffCommand(MAV_CMD command) const
{
    const MissionCommandList *const commandList = _staticCommandTree[beeCopterMAVLink::FirmwareClassGeneric][beeCopterMAVLink::VehicleClassGeneric];
    const MissionCommandUIInfo *const uiInfo = commandList->getUIInfo(command);

    return (uiInfo && uiInfo->isTakeoffCommand());
}

const QList<MAV_CMD> &MissionCommandTree::allCommandIds() const
{
    return _staticCommandTree[beeCopterMAVLink::FirmwareClassGeneric][beeCopterMAVLink::VehicleClassGeneric]->commandIds();
}

const MissionCommandUIInfo *MissionCommandTree::getUIInfo(Vehicle* vehicle, beeCopterMAVLink::VehicleClass_t vtolMode,  MAV_CMD command)
{
    beeCopterMAVLink::FirmwareClass_t firmwareClass;
    beeCopterMAVLink::VehicleClass_t vehicleClass;

    _firmwareAndVehicleClassInfo(vehicle, vtolMode, firmwareClass, vehicleClass);
    _buildAllCommands(vehicle, vtolMode);

    MissionCommandUIInfo *result = nullptr;

    const QMap<MAV_CMD, MissionCommandUIInfo*> &infoMap = _allCommands[firmwareClass][vehicleClass];
    if (infoMap.contains(command)) {
        result = infoMap[command];
    }

    return result;
}

QStringList MissionCommandTree::categoriesForVehicle(Vehicle *vehicle)
{
    return _availableCategoriesForVehicle(vehicle);
}

QVariantList MissionCommandTree::getCommandsForCategory(Vehicle *vehicle, const QString &category, bool showFlyThroughCommands)
{
    beeCopterMAVLink::FirmwareClass_t firmwareClass;
    beeCopterMAVLink::VehicleClass_t vehicleClass;

    _firmwareAndVehicleClassInfo(vehicle, beeCopterMAVLink::VehicleClassGeneric, firmwareClass, vehicleClass);
    _buildAllCommands(vehicle, beeCopterMAVLink::VehicleClassGeneric);

    // vehicle can be null in which case _firmwareAndVehicleClassInfo will tell of the firmware/vehicle type for the offline editing vehicle.
    // We then use that to get a firmware plugin so we can get the list of supported commands.
    const FirmwarePlugin *const firmwarePlugin = FirmwarePluginManager::instance()->firmwarePluginForAutopilot(beeCopterMAVLink::firmwareClassToAutopilot(firmwareClass), beeCopterMAVLink::vehicleClassToMavType(vehicleClass));
    const QList<MAV_CMD> supportedCommands = firmwarePlugin->supportedMissionCommands(vehicleClass);

    const QMap<MAV_CMD, MissionCommandUIInfo*> commandMap = _allCommands[firmwareClass][vehicleClass];
    QVariantList list;
    for (const MAV_CMD command: commandMap.keys()) {
        if (supportedCommands.isEmpty() || supportedCommands.contains(command)) {
            MissionCommandUIInfo* uiInfo = commandMap[command];
            if ((uiInfo->category() == category || category == _allCommandsCategory) && (showFlyThroughCommands || !uiInfo->specifiesCoordinate() || uiInfo->isStandaloneCoordinate())) {
                list.append(QVariant::fromValue(uiInfo));
            }
        }
    }

    return list;
}

void MissionCommandTree::_firmwareAndVehicleClassInfo(Vehicle *vehicle, beeCopterMAVLink::VehicleClass_t vtolMode, beeCopterMAVLink::FirmwareClass_t &firmwareClass, beeCopterMAVLink::VehicleClass_t &vehicleClass) const
{
    firmwareClass = beeCopterMAVLink::firmwareClass(vehicle->firmwareType());
    vehicleClass = beeCopterMAVLink::vehicleClass(vehicle->vehicleType());
    if ((vehicleClass == beeCopterMAVLink::VehicleClassVTOL) && (vtolMode != beeCopterMAVLink::VehicleClassGeneric)) {
        vehicleClass = vtolMode;
    }
}
