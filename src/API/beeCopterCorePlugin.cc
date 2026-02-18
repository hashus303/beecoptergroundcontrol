#include "beeCopterCorePlugin.h"
#include "beeCopterLogging.h"
#include "AppSettings.h"
#include "MavlinkSettings.h"
#include "FactMetaData.h"
#ifdef beeCopter_GST_STREAMING
#include "GStreamer.h"
#endif
#include "HorizontalFactValueGrid.h"
#include "InstrumentValueData.h"
#include "JoystickManager.h"
#include "MAVLinkLib.h"
#include "beeCopterLoggingCategory.h"
#include "beeCopterOptions.h"
#include "QmlComponentInfo.h"
#include "QmlObjectListModel.h"
#ifdef beeCopter_QT_STREAMING
#include "QtMultimediaReceiver.h"
#endif
#include "SettingsManager.h"
#include "VideoReceiver.h"

#ifdef beeCopter_CUSTOM_BUILD
#include CUSTOMHEADER
#endif

#include <QtCore/QApplicationStatic>
#include <QtCore/QFile>
#include <QtQml/qqml.h>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickItem>

beeCopter_LOGGING_CATEGORY(beeCopterCorePluginLog, "API.beeCopterCorePlugin");

#ifndef beeCopter_CUSTOM_BUILD
Q_APPLICATION_STATIC(beeCopterCorePlugin, _beeCopterCorePluginInstance);
#endif

beeCopterCorePlugin::beeCopterCorePlugin(QObject *parent)
    : QObject(parent)
    , _defaultOptions(new beeCopterOptions(this))
    , _emptyCustomMapItems(new QmlObjectListModel(this))
{
    qCDebug(beeCopterCorePluginLog) << this;
}

beeCopterCorePlugin::~beeCopterCorePlugin()
{
    qCDebug(beeCopterCorePluginLog) << this;
}

beeCopterCorePlugin *beeCopterCorePlugin::instance()
{
#ifndef beeCopter_CUSTOM_BUILD
    return _beeCopterCorePluginInstance();
#else
    return CUSTOMCLASS::instance();
#endif
}

const QVariantList &beeCopterCorePlugin::analyzePages()
{
    static const QVariantList analyzeList = {
        QVariant::fromValue(new QmlComponentInfo(
            tr("Log Download"),
            QUrl::fromUserInput(QStringLiteral("qrc:/qml/beeCopter/AnalyzeView/LogDownloadPage.qml")),
            QUrl::fromUserInput(QStringLiteral("qrc:/qmlimages/LogDownloadIcon.svg")))),
        QVariant::fromValue(new QmlComponentInfo(
            tr("GeoTag Images"),
            QUrl::fromUserInput(QStringLiteral("qrc:/qml/beeCopter/AnalyzeView/GeoTag/GeoTagPage.qml")),
            QUrl::fromUserInput(QStringLiteral("qrc:/qml/beeCopter/AnalyzeView/GeoTag/GeoTagIcon.svg")))),
        QVariant::fromValue(new QmlComponentInfo(
            tr("MAVLink Console"),
            QUrl::fromUserInput(QStringLiteral("qrc:/qml/beeCopter/AnalyzeView/MAVLinkConsolePage.qml")),
            QUrl::fromUserInput(QStringLiteral("qrc:/qmlimages/MAVLinkConsoleIcon.svg")))),
#ifndef beeCopter_DISABLE_MAVLINK_INSPECTOR
        QVariant::fromValue(new QmlComponentInfo(
            tr("MAVLink Inspector"),
            QUrl::fromUserInput(QStringLiteral("qrc:/qml/beeCopter/AnalyzeView/MAVLinkInspectorPage.qml")),
            QUrl::fromUserInput(QStringLiteral("qrc:/qmlimages/MAVLinkInspector.svg")))),
#endif
        QVariant::fromValue(new QmlComponentInfo(
            tr("Vibration"),
            QUrl::fromUserInput(QStringLiteral("qrc:/qml/beeCopter/AnalyzeView/VibrationPage.qml")),
            QUrl::fromUserInput(QStringLiteral("qrc:/qmlimages/VibrationPageIcon")))),
    };

    return analyzeList;
}

beeCopterOptions *beeCopterCorePlugin::options()
{
    return _defaultOptions;
}

const QmlObjectListModel *beeCopterCorePlugin::customMapItems()
{
    return _emptyCustomMapItems;
}

void beeCopterCorePlugin::adjustSettingMetaData(const QString &settingsGroup, FactMetaData &metaData, bool &visible)
{
#ifdef Q_OS_ANDROID
    Q_UNUSED(visible);
#endif

    if (settingsGroup == AppSettings::settingsGroup) {
        if (metaData.name() == AppSettings::indoorPaletteName) {
            QVariant outdoorPalette;
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
            outdoorPalette = 0;
#else
            outdoorPalette = 1;
#endif
            metaData.setRawDefaultValue(outdoorPalette);
            return;
        }
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
        else if (metaData.name() == MavlinkSettings::telemetrySaveName) {
            metaData.setRawDefaultValue(false);
            return;
        }
#endif
#ifndef Q_OS_ANDROID
        else if (metaData.name() == AppSettings::androidDontSaveToSDCardName) {
            visible = false;
            return;
        }
#endif
    }
}

QString beeCopterCorePlugin::showAdvancedUIMessage() const
{
    return tr("WARNING: You are about to enter Advanced Mode. "
              "If used incorrectly, this may cause your vehicle to malfunction thus voiding your warranty. "
              "You should do so only if instructed by customer support. "
              "Are you sure you want to enable Advanced Mode?");
}

void beeCopterCorePlugin::factValueGridCreateDefaultSettings(FactValueGrid* factValueGrid)
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    FactValueGrid::FontSize defaultFontSize = FactValueGrid::DefaultFontSize;
#else
    FactValueGrid::FontSize defaultFontSize = FactValueGrid::MediumFontSize;
#endif

    if (factValueGrid->specificVehicleForCard()) {
        bool includeFWValues = factValueGrid->vehicleClass() == beeCopterMAVLink::VehicleClassFixedWing || factValueGrid->vehicleClass() == beeCopterMAVLink::VehicleClassVTOL || factValueGrid->vehicleClass() == beeCopterMAVLink::VehicleClassAirship;

        factValueGrid->setFontSize(defaultFontSize);
        factValueGrid->appendColumn();
        factValueGrid->appendColumn();

        int rowIndex = 0;
        int colIndex = 0;

        // first cell
        QmlObjectListModel* column = factValueGrid->columns()->value<QmlObjectListModel*>(colIndex++);
        InstrumentValueData* value = column->value<InstrumentValueData*>(rowIndex);
        value->setFact("Vehicle", "AltitudeRelative");
        value->setIcon("arrow-thick-up.svg");
        value->setText(value->fact()->shortDescription());
        value->setShowUnits(true);

        // second cell
        column = factValueGrid->columns()->value<QmlObjectListModel*>(colIndex++);
        value = column->value<InstrumentValueData*>(rowIndex);
        if (includeFWValues) {
            value->setFact("Vehicle", "AirSpeed");
            value->setText("AirSpd");
            value->setShowUnits(true);
        } else {
            value->setFact("Vehicle", "GroundSpeed");
            value->setIcon("arrow-simple-right.svg");
            value->setText(value->fact()->shortDescription());
            value->setShowUnits(true);
        }
    } else {
        const bool includeFWValues = ((factValueGrid->vehicleClass() == beeCopterMAVLink::VehicleClassFixedWing) || (factValueGrid->vehicleClass() == beeCopterMAVLink::VehicleClassVTOL) || (factValueGrid->vehicleClass() == beeCopterMAVLink::VehicleClassAirship));

        factValueGrid->setFontSize(defaultFontSize);

        (void) factValueGrid->appendColumn();
        (void) factValueGrid->appendColumn();
        (void) factValueGrid->appendColumn();
        if (includeFWValues) {
            (void) factValueGrid->appendColumn();
        }
        factValueGrid->appendRow();

        int rowIndex = 0;
        QmlObjectListModel *column = factValueGrid->columns()->value<QmlObjectListModel*>(0);

        InstrumentValueData *value = column->value<InstrumentValueData*>(rowIndex++);
        value->setFact(QStringLiteral("Vehicle"), QStringLiteral("AltitudeRelative"));
        value->setIcon(QStringLiteral("arrow-thick-up.svg"));
        value->setText(value->fact()->shortDescription());
        value->setShowUnits(true);

        value = column->value<InstrumentValueData*>(rowIndex++);
        value->setFact(QStringLiteral("Vehicle"), QStringLiteral("DistanceToHome"));
        value->setIcon(QStringLiteral("bookmark copy 3.svg"));
        value->setText(value->fact()->shortDescription());
        value->setShowUnits(true);

        rowIndex = 0;
        column = factValueGrid->columns()->value<QmlObjectListModel*>(1);

        value = column->value<InstrumentValueData*>(rowIndex++);
        value->setFact(QStringLiteral("Vehicle"), QStringLiteral("ClimbRate"));
        value->setIcon(QStringLiteral("arrow-simple-up.svg"));
        value->setText(value->fact()->shortDescription());
        value->setShowUnits(true);

        value = column->value<InstrumentValueData*>(rowIndex++);
        value->setFact(QStringLiteral("Vehicle"), QStringLiteral("GroundSpeed"));
        value->setIcon(QStringLiteral("arrow-simple-right.svg"));
        value->setText(value->fact()->shortDescription());
        value->setShowUnits(true);

        if (includeFWValues) {
            rowIndex = 0;
            column = factValueGrid->columns()->value<QmlObjectListModel*>(2);

            value = column->value<InstrumentValueData*>(rowIndex++);
            value->setFact(QStringLiteral("Vehicle"), QStringLiteral("AirSpeed"));
            value->setText(QStringLiteral("AirSpd"));
            value->setShowUnits(true);

            value = column->value<InstrumentValueData*>(rowIndex++);
            value->setFact(QStringLiteral("Vehicle"), QStringLiteral("ThrottlePct"));
            value->setText(QStringLiteral("Thr"));
            value->setShowUnits(true);
        }

        rowIndex = 0;
        column = factValueGrid->columns()->value<QmlObjectListModel*>(includeFWValues ? 3 : 2);

        value = column->value<InstrumentValueData*>(rowIndex++);
        value->setFact(QStringLiteral("Vehicle"), QStringLiteral("FlightTime"));
        value->setIcon(QStringLiteral("timer.svg"));
        value->setText(value->fact()->shortDescription());
        value->setShowUnits(false);

        value = column->value<InstrumentValueData*>(rowIndex++);
        value->setFact(QStringLiteral("Vehicle"), QStringLiteral("FlightDistance"));
        value->setIcon(QStringLiteral("travel-walk.svg"));
        value->setText(value->fact()->shortDescription());
        value->setShowUnits(true);
    }
}

QQmlApplicationEngine *beeCopterCorePlugin::createQmlApplicationEngine(QObject *parent)
{
    QQmlApplicationEngine *const qmlEngine = new QQmlApplicationEngine(parent);
    qmlEngine->addImportPath(QStringLiteral("qrc:/qml"));
    qmlEngine->rootContext()->setContextProperty(QStringLiteral("joystickManager"), JoystickManager::instance());
    qmlEngine->rootContext()->setContextProperty(QStringLiteral("debugMessageModel"), beeCopterLogging::instance());
    return qmlEngine;
}

void beeCopterCorePlugin::createRootWindow(QQmlApplicationEngine *qmlEngine)
{
    qmlEngine->load(QUrl(QStringLiteral("qrc:/qml/beeCopter/MainWindow.qml")));
}

VideoReceiver *beeCopterCorePlugin::createVideoReceiver(QObject *parent)
{
#ifdef beeCopter_GST_STREAMING
    return GStreamer::createVideoReceiver(parent);
#elif defined(beeCopter_QT_STREAMING)
    return QtMultimediaReceiver::createVideoReceiver(parent);
#else
    return nullptr;
#endif
}

void *beeCopterCorePlugin::createVideoSink(QQuickItem *widget, QObject *parent)
{
#ifdef beeCopter_GST_STREAMING
    return GStreamer::createVideoSink(widget, parent);
#elif defined(beeCopter_QT_STREAMING)
    return QtMultimediaReceiver::createVideoSink(widget, parent);
#else
    Q_UNUSED(widget); Q_UNUSED(parent);
    return nullptr;
#endif
}
void beeCopterCorePlugin::releaseVideoSink(void *sink)
{
#ifdef beeCopter_GST_STREAMING
    GStreamer::releaseVideoSink(sink);
#elif defined(beeCopter_QT_STREAMING)
    QtMultimediaReceiver::releaseVideoSink(sink);
#else
    Q_UNUSED(sink);
#endif
}

const QVariantList &beeCopterCorePlugin::toolBarIndicators()
{
    static const QVariantList toolBarIndicatorList = QVariantList(
        {
            QVariant::fromValue(QUrl::fromUserInput(QStringLiteral("qrc:/qml/beeCopter/Toolbar/RTKGPSIndicator.qml"))),
        }
    );

    return toolBarIndicatorList;
}

QVariantList beeCopterCorePlugin::firstRunPromptsToShow()
{
    QList<int> rgIdsToShow;

    rgIdsToShow.append(firstRunPromptStdIds());
    rgIdsToShow.append(firstRunPromptCustomIds());

    const QList<int> rgAlreadyShownIds = AppSettings::firstRunPromptsIdsVariantToList(SettingsManager::instance()->appSettings()->firstRunPromptIdsShown()->rawValue());
    for (int idToRemove: rgAlreadyShownIds) {
        (void) rgIdsToShow.removeOne(idToRemove);
    }

    QVariantList rgVarIdsToShow;
    for (int id: rgIdsToShow) {
        rgVarIdsToShow.append(id);
    }

    return rgVarIdsToShow;
}

QString beeCopterCorePlugin::firstRunPromptResource(int id) const
{
    switch (id) {
    case kUnitsFirstRunPromptId:
        return QStringLiteral("/qml/beeCopter/FirstRunPromptDialogs/UnitsFirstRunPrompt.qml");
    case kOfflineVehicleFirstRunPromptId:
        return QStringLiteral("/qml/beeCopter/FirstRunPromptDialogs/OfflineVehicleFirstRunPrompt.qml");
    default:
        return QString();
    }
}

void beeCopterCorePlugin::_setShowTouchAreas(bool show)
{
    if (show != _showTouchAreas) {
        _showTouchAreas = show;
        emit showTouchAreasChanged(show);
    }
}

void beeCopterCorePlugin::_setShowAdvancedUI(bool show)
{
    if (show != _showAdvancedUI) {
        _showAdvancedUI = show;
        emit showAdvancedUIChanged(show);
    }
}
