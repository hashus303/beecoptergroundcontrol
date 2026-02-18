#include "beeCopterApplication.h"
#include "beeCopter_version.h"

#include <QtCore/QEvent>
#include <QtCore/QFile>
#include <QtCore/QMetaMethod>
#include <QtCore/QMetaObject>
#include <QtCore/QRegularExpression>
#include <QtGui/QFontDatabase>
#include <QtGui/QIcon>
#include "beeCopterNetworkHelper.h"
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickImageProvider>
#include <QtQuick/QQuickWindow>
#include <QtQuickControls2/QQuickStyle>
#include <QtSvg/QSvgRenderer>

#include <QtCore/private/qthread_p.h>

#include "beeCopterLogging.h"
#include "AudioOutput.h"
#include "FollowMe.h"
#include "JoystickManager.h"
#include "JsonHelper.h"
#include "LinkManager.h"
#include "MAVLinkProtocol.h"
#include "MultiVehicleManager.h"
#include "ParameterManager.h"
#include "PositionManager.h"
#include "beeCopterCommandLineParser.h"
#include "beeCopterCorePlugin.h"
#include "beeCopterFileDownload.h"
#include "beeCopterImageProvider.h"
#include "beeCopterLoggingCategory.h"
#include "SettingsManager.h"
#include "MavlinkSettings.h"
#include "AppSettings.h"
#include "UDPLink.h"
#include "Vehicle.h"
#include "VehicleComponent.h"
#include "VideoManager.h"

#ifndef beeCopter_NO_SERIAL_LINK
#include "SerialLink.h"
#endif

beeCopter_LOGGING_CATEGORY(beeCopterApplicationLog, "API.beeCopterApplication")

beeCopterApplication::beeCopterApplication(int &argc, char *argv[], const beeCopterCommandLineParser::CommandLineParseResult &cli)
    : QApplication(argc, argv)
    , _runningUnitTests(cli.runningUnitTests)
    , _simpleBootTest(cli.simpleBootTest)
    , _fakeMobile(cli.fakeMobile)
    , _logOutput(cli.logOutput)
    , _systemId(cli.systemId.value_or(0))
{
    _msecsElapsedTime.start();

    // Setup for network proxy support
    beeCopterNetworkHelper::initializeProxySupport();

    bool fClearSettingsOptions = cli.clearSettingsOptions;  // Clear stored settings
    const bool fClearCache = cli.clearCache;                // Clear parameter/airframe caches
    const QString loggingOptions = cli.loggingOptions.value_or(QString(""));

    // Set up timer for delayed missing fact display
    _missingParamsDelayedDisplayTimer.setSingleShot(true);
    _missingParamsDelayedDisplayTimer.setInterval(_missingParamsDelayedDisplayTimerTimeout);
    (void) connect(&_missingParamsDelayedDisplayTimer, &QTimer::timeout, this, &beeCopterApplication::_missingParamsDisplay);

    // Set application information
    QString applicationName;
    if (_runningUnitTests || _simpleBootTest) {
        // We don't want unit tests to use the same QSettings space as the normal app. So we tweak the app
        // name. Also we want to run unit tests with clean settings every time.
        // Include test name or PID to prevent settings file conflicts when tests run in parallel
        if (!cli.unitTests.isEmpty()) {
            applicationName = QStringLiteral("%1_unittest_%2").arg(beeCopter_APP_NAME, cli.unitTests.first());
        } else {
            applicationName = QStringLiteral("%1_unittest_%2").arg(beeCopter_APP_NAME).arg(QCoreApplication::applicationPid());
        }
    } else {
#ifdef beeCopter_DAILY_BUILD
        // This gives daily builds their own separate settings space. Allowing you to use daily and stable builds
        // side by side without daily screwing up your stable settings.
        applicationName = QStringLiteral("%1 Daily").arg(beeCopter_APP_NAME);
#else
        applicationName = beeCopter_APP_NAME;
#endif
    }
    setApplicationName(applicationName);
    setOrganizationName(beeCopter_ORG_NAME);
    setOrganizationDomain(beeCopter_ORG_DOMAIN);
    setApplicationVersion(QString(beeCopter_APP_VERSION_STR));

    // Set settings format
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings settings;
    qCDebug(beeCopterApplicationLog) << "Settings location" << settings.fileName() << "Is writable?:" << settings.isWritable();

    if (!settings.isWritable()) {
        qCWarning(beeCopterApplicationLog) << "Setings location is not writable";
    }

    // The setting will delete all settings on this boot
    fClearSettingsOptions |= settings.contains(_deleteAllSettingsKey);

    if (_runningUnitTests || _simpleBootTest) {
        // Unit tests run with clean settings
        fClearSettingsOptions = true;
    }

    if (fClearSettingsOptions) {
        // User requested settings to be cleared on command line
        settings.clear();

        // Clear parameter cache
        QDir paramDir(ParameterManager::parameterCacheDir());
        paramDir.removeRecursively();
        paramDir.mkpath(paramDir.absolutePath());
    } else {
        // Determine if upgrade message for settings version bump is required. Check and clear must happen before toolbox is started since
        // that will write some settings.
        if (settings.contains(_settingsVersionKey)) {
            if (settings.value(_settingsVersionKey).toInt() != beeCopter_SETTINGS_VERSION) {
                settings.clear();
                _settingsUpgraded = true;
            }
        }
    }
    settings.setValue(_settingsVersionKey, beeCopter_SETTINGS_VERSION);

    if (fClearCache) {
        QDir dir(ParameterManager::parameterCacheDir());
        dir.removeRecursively();
        QFile airframe(cachedAirframeMetaDataFile());
        airframe.remove();
        QFile parameter(cachedParameterMetaDataFile());
        parameter.remove();
    }

    // Set up our logging filters
    beeCopterLoggingCategoryManager::instance()->setFilterRulesFromSettings(loggingOptions);

    // We need to set language as early as possible prior to loading on JSON files.
    setLanguage();

    // Force old SVG Tiny 1.2 behavior for compatibility
    QSvgRenderer::setDefaultOptions(QtSvg::Tiny12FeaturesOnly);

#ifndef beeCopter_DAILY_BUILD
    _checkForNewVersion();
#endif
}

void beeCopterApplication::setLanguage()
{
    _locale = QLocale::system();
    qCDebug(beeCopterApplicationLog) << "System reported locale:" << _locale << "; Name" << _locale.name() << "; Preffered (used in maps): " << (QLocale::system().uiLanguages().length() > 0 ? QLocale::system().uiLanguages()[0] : "None");

    QLocale::Language possibleLocale = AppSettings::_qLocaleLanguageEarlyAccess();
    if (possibleLocale != QLocale::AnyLanguage) {
        _locale = QLocale(possibleLocale);
    }
    //-- We have specific fonts for Korean
    if (_locale == QLocale::Korean) {
        qCDebug(beeCopterApplicationLog) << "Loading Korean fonts" << _locale.name();
        if(QFontDatabase::addApplicationFont(":/fonts/NanumGothic-Regular") < 0) {
            qCWarning(beeCopterApplicationLog) << "Could not load /fonts/NanumGothic-Regular font";
        }
        if(QFontDatabase::addApplicationFont(":/fonts/NanumGothic-Bold") < 0) {
            qCWarning(beeCopterApplicationLog) << "Could not load /fonts/NanumGothic-Bold font";
        }
    }
    qCDebug(beeCopterApplicationLog) << "Loading localizations for" << _locale.name();
    removeTranslator(JsonHelper::translator());
    removeTranslator(&_beeCopterTranslatorSourceCode);
    removeTranslator(&_beeCopterTranslatorQtLibs);
    if (_locale.name() != "en_US") {
        QLocale::setDefault(_locale);
        if (_beeCopterTranslatorQtLibs.load("qt_" + _locale.name(), QLibraryInfo::path(QLibraryInfo::TranslationsPath))) {
            installTranslator(&_beeCopterTranslatorQtLibs);
        } else {
            qCWarning(beeCopterApplicationLog) << "Qt lib localization for" << _locale.name() << "is not present";
        }
        if (_beeCopterTranslatorSourceCode.load(_locale, QLatin1String("beeCopter_source_"), "", ":/i18n")) {
            installTranslator(&_beeCopterTranslatorSourceCode);
        } else {
            qCWarning(beeCopterApplicationLog) << "Error loading source localization for" << _locale.name();
        }
        if (JsonHelper::translator()->load(_locale, QLatin1String("beeCopter_json_"), "", ":/i18n")) {
            installTranslator(JsonHelper::translator());
        } else {
            qCWarning(beeCopterApplicationLog) << "Error loading json localization for" << _locale.name();
        }
    }

    if (_qmlAppEngine) {
        _qmlAppEngine->retranslate();
    }

    emit languageChanged(_locale);
}

beeCopterApplication::~beeCopterApplication()
{

}

void beeCopterApplication::init()
{
    SettingsManager::instance()->init();
    if (_systemId > 0) {
        qCDebug(beeCopterApplicationLog) << "Setting MAVLink System ID to:" << _systemId;
        SettingsManager::instance()->mavlinkSettings()->gcsMavlinkSystemID()->setRawValue(_systemId);
    }

    // Although this should really be in _initForNormalAppBoot putting it here allowws us to create unit tests which pop up more easily
    if (QFontDatabase::addApplicationFont(":/fonts/opensans") < 0) {
        qCWarning(beeCopterApplicationLog) << "Could not load /fonts/opensans font";
    }

    if (QFontDatabase::addApplicationFont(":/fonts/opensans-demibold") < 0) {
        qCWarning(beeCopterApplicationLog) << "Could not load /fonts/opensans-demibold font";
    }

    if (_simpleBootTest) {
        // Since GStream builds are so problematic we initialize video during the simple boot test
        // to make sure it works and verfies plugin availability.
        _initVideo();
    } else if (!_runningUnitTests) {
        _initForNormalAppBoot();
    }
}

void beeCopterApplication::_initVideo()
{
#ifdef beeCopter_GST_STREAMING
    // Gstreamer video playback requires OpenGL
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);
#endif

    beeCopterCorePlugin::instance();  // CorePlugin must be initialized before VideoManager for Video Cleanup
    VideoManager::instance();
    _videoManagerInitialized = true;
}

void beeCopterApplication::_initForNormalAppBoot()
{
    _initVideo(); // GStreamer must be initialized before QmlEngine

    QQuickStyle::setStyle("Basic");
    beeCopterCorePlugin::instance()->init();
    MAVLinkProtocol::instance()->init();
    MultiVehicleManager::instance()->init();
    _qmlAppEngine = beeCopterCorePlugin::instance()->createQmlApplicationEngine(this);
    QObject::connect(_qmlAppEngine, &QQmlApplicationEngine::objectCreationFailed, this, QCoreApplication::quit, Qt::QueuedConnection);
    beeCopterCorePlugin::instance()->createRootWindow(_qmlAppEngine);

    AudioOutput::instance()->init(SettingsManager::instance()->appSettings()->audioMuted());
    FollowMe::instance()->init();
    beeCopterPositionManager::instance()->init();
    LinkManager::instance()->init();
    VideoManager::instance()->init(mainRootWindow());

    // Image provider for Optical Flow
    _qmlAppEngine->addImageProvider(_beeCopterImageProviderId, new beeCopterImageProvider());

    // Set the window icon now that custom plugin has a chance to override it
#ifdef Q_OS_LINUX
    QUrl windowIcon = QUrl("qrc:/res/beeCopter.ico");
    windowIcon = _qmlAppEngine->interceptUrl(windowIcon, QQmlAbstractUrlInterceptor::UrlString);
    // The interceptor needs "qrc:/path" but QIcon expects ":/path"
    setWindowIcon(QIcon(":" + windowIcon.path()));
#endif

    // Safe to show popup error messages now that main window is created
    _showErrorsInToolbar = true;

    #ifdef Q_OS_LINUX
    #ifndef Q_OS_ANDROID
    #ifndef beeCopter_NO_SERIAL_LINK
        if (!_runningUnitTests) {
            // Determine if we have the correct permissions to access USB serial devices
            QFile permFile("/etc/group");
            if(permFile.open(QIODevice::ReadOnly)) {
                while(!permFile.atEnd()) {
                    const QString line = permFile.readLine();
                    if (line.contains("dialout") && !line.contains(getenv("USER"))) {
                        permFile.close();
                        showAppMessage(tr(
                            "The current user does not have the correct permissions to access serial devices. "
                            "You should also remove modemmanager since it also interferes.<br/><br/>"
                            "If you are using Ubuntu, execute the following commands to fix these issues:<br/>"
                            "<pre>sudo usermod -a -G dialout $USER<br/>"
                            "sudo apt-get remove modemmanager</pre>"));
                        break;
                    }
                }
                permFile.close();
            }
        }
    #endif
    #endif
    #endif

    // Now that main window is up check for lost log files
    MAVLinkProtocol::instance()->checkForLostLogFiles();

    // Load known link configurations
    LinkManager::instance()->loadLinkConfigurationList();

    // Probe for joysticks
    JoystickManager::instance()->init();

    if (_settingsUpgraded) {
        showAppMessage(tr("The format for %1 saved settings has been modified. "
                    "Your saved settings have been reset to defaults.").arg(applicationName()));
    }

    // Connect links with flag AutoconnectLink
    LinkManager::instance()->startAutoConnectedLinks();
}

void beeCopterApplication::deleteAllSettingsNextBoot()
{
    QSettings settings;
    settings.setValue(_deleteAllSettingsKey, true);
}

void beeCopterApplication::clearDeleteAllSettingsNextBoot()
{
    QSettings settings;
    settings.remove(_deleteAllSettingsKey);
}

void beeCopterApplication::reportMissingParameter(int componentId, const QString &name)
{
    const QPair<int, QString> missingParam(componentId, name);

    if (!_missingParams.contains(missingParam)) {
        _missingParams.append(missingParam);
    }
    _missingParamsDelayedDisplayTimer.start();
}

void beeCopterApplication::_missingParamsDisplay()
{
    if (_missingParams.isEmpty()) {
        return;
    }

    QString params;
    for (QPair<int, QString>& missingParam: _missingParams) {
        const QString param = QStringLiteral("%1:%2").arg(missingParam.first).arg(missingParam.second);
        if (params.isEmpty()) {
            params += param;
        } else {
            params += QStringLiteral(", %1").arg(param);
        }

    }
    _missingParams.clear();

    showAppMessage(tr("Parameters are missing from firmware. You may be running a version of firmware which is not fully supported or your firmware has a bug in it. Missing params: %1").arg(params));
}

QObject *beeCopterApplication::_rootQmlObject()
{
    if (_qmlAppEngine && _qmlAppEngine->rootObjects().size()) {
        return _qmlAppEngine->rootObjects()[0];
    }

    return nullptr;
}

void beeCopterApplication::showCriticalVehicleMessage(const QString &message)
{
    // PreArm messages are handled by Vehicle and shown in Map
    if (message.startsWith(QStringLiteral("PreArm")) || message.startsWith(QStringLiteral("preflight"), Qt::CaseInsensitive)) {
        return;
    }

    QObject *const rootQmlObject = _rootQmlObject();
    if (rootQmlObject && _showErrorsInToolbar) {
        QVariant varReturn;
        QVariant varMessage = QVariant::fromValue(message);
        QMetaObject::invokeMethod(rootQmlObject, "showCriticalVehicleMessage", Q_RETURN_ARG(QVariant, varReturn), Q_ARG(QVariant, varMessage));
    } else if (runningUnitTests() || !_showErrorsInToolbar) {
        // Unit tests can run without UI
        qCDebug(beeCopterApplicationLog) << "beeCopterApplication::showCriticalVehicleMessage unittest" << message;
    } else {
        qCWarning(beeCopterApplicationLog) << "Internal error";
    }
}

void beeCopterApplication::showAppMessage(const QString &message, const QString &title)
{
    const QString dialogTitle = title.isEmpty() ? applicationName() : title;

    QObject *const rootQmlObject = _rootQmlObject();
    if (rootQmlObject) {
        QVariant varReturn;
        QVariant varMessage = QVariant::fromValue(message);
        QMetaObject::invokeMethod(rootQmlObject, "_showMessageDialog", Q_RETURN_ARG(QVariant, varReturn), Q_ARG(QVariant, dialogTitle), Q_ARG(QVariant, varMessage));
    } else if (runningUnitTests()) {
        // Unit tests can run without UI
        // We don't use a logging category to make it easier to debug unit tests
        qDebug() << "beeCopterApplication::showAppMessage unittest title:message" << dialogTitle << message;
    } else {
        // UI isn't ready yet
        _delayedAppMessages.append(QPair<QString, QString>(dialogTitle, message));
        QTimer::singleShot(200, this, &beeCopterApplication::_showDelayedAppMessages);
    }
}

void beeCopterApplication::showRebootAppMessage(const QString &message, const QString &title)
{
    static QTime lastRebootMessage;

    const QTime currentTime = QTime::currentTime();
    const QTime previousTime = lastRebootMessage;
    lastRebootMessage = currentTime;

    if (previousTime.isValid() && (previousTime.msecsTo(currentTime) < (60 * 1000 * 2))) {
        // Debounce reboot messages
        return;
    }

    showAppMessage(message, title);
}

void beeCopterApplication::_showDelayedAppMessages()
{
    if (_rootQmlObject()) {
        for (const QPair<QString, QString>& appMsg: _delayedAppMessages) {
            showAppMessage(appMsg.second, appMsg.first);
        }
        _delayedAppMessages.clear();
    } else {
        QTimer::singleShot(200, this, &beeCopterApplication::_showDelayedAppMessages);
    }
}

QQuickWindow *beeCopterApplication::mainRootWindow()
{
    if (!_mainRootWindow) {
        _mainRootWindow = qobject_cast<QQuickWindow*>(_rootQmlObject());
    }

    return _mainRootWindow;
}

void beeCopterApplication::showVehicleConfig()
{
    if (_rootQmlObject()) {
      QMetaObject::invokeMethod(_rootQmlObject(), "showVehicleConfig");
    }
}

void beeCopterApplication::qmlAttemptWindowClose()
{
    if (_rootQmlObject()) {
        QMetaObject::invokeMethod(_rootQmlObject(), "attemptWindowClose");
    }
}

void beeCopterApplication::_checkForNewVersion()
{
    if (_runningUnitTests) {
        return;
    }

    if (!_parseVersionText(applicationVersion(), _majorVersion, _minorVersion, _buildVersion)) {
        return;
    }

    const QString versionCheckFile = beeCopterCorePlugin::instance()->stableVersionCheckFileUrl();
    if (!versionCheckFile.isEmpty()) {
        beeCopterFileDownload *const download = new beeCopterFileDownload(this);
        (void) connect(download, &beeCopterFileDownload::finished, this, &beeCopterApplication::_beeCopterCurrentStableVersionDownloadComplete);
        if (!download->start(versionCheckFile)) {
            qCDebug(beeCopterApplicationLog) << "Download beeCopter stable version failed to start" << download->errorString();
            download->deleteLater();
        }
    }
}

void beeCopterApplication::_beeCopterCurrentStableVersionDownloadComplete(bool success, const QString &localFile, const QString &errorMsg)
{
    if (success) {
        QFile versionFile(localFile);
        if (versionFile.open(QIODevice::ReadOnly)) {
            QTextStream textStream(&versionFile);
            const QString version = textStream.readLine();

            qCDebug(beeCopterApplicationLog) << version;

            int majorVersion, minorVersion, buildVersion;
            if (_parseVersionText(version, majorVersion, minorVersion, buildVersion)) {
                if (_majorVersion < majorVersion ||
                        ((_majorVersion == majorVersion) && (_minorVersion < minorVersion)) ||
                        ((_majorVersion == majorVersion) && (_minorVersion == minorVersion) && (_buildVersion < buildVersion))) {
                    showAppMessage(tr("There is a newer version of %1 available. You can download it from %2.").arg(applicationName()).arg(beeCopterCorePlugin::instance()->stableDownloadLocation()), tr("New Version Available"));
                }
            }
        }
    } else if (!errorMsg.isEmpty()) {
        qCDebug(beeCopterApplicationLog) << "Download beeCopter stable version failed" << errorMsg;
    }

    sender()->deleteLater();
}

bool beeCopterApplication::_parseVersionText(const QString &versionString, int &majorVersion, int &minorVersion, int &buildVersion)
{
    static const QRegularExpression regExp("v(\\d+)\\.(\\d+)\\.(\\d+)");
    const QRegularExpressionMatch match = regExp.match(versionString);
    if (match.hasMatch() && match.lastCapturedIndex() == 3) {
        majorVersion = match.captured(1).toInt();
        minorVersion = match.captured(2).toInt();
        buildVersion = match.captured(3).toInt();
        return true;
    }

    return false;
}

QString beeCopterApplication::cachedParameterMetaDataFile()
{
    QSettings settings;
    const QDir parameterDir = QFileInfo(settings.fileName()).dir();
    return parameterDir.filePath(QStringLiteral("ParameterFactMetaData.xml"));
}

QString beeCopterApplication::cachedAirframeMetaDataFile()
{
    QSettings settings;
    const QDir airframeDir = QFileInfo(settings.fileName()).dir();
    return airframeDir.filePath(QStringLiteral("PX4AirframeFactMetaData.xml"));
}

int beeCopterApplication::CompressedSignalList::_signalIndex(const QMetaMethod &method)
{
    if (method.methodType() != QMetaMethod::Signal) {
        qCWarning(beeCopterApplicationLog) << "Internal error:" << Q_FUNC_INFO <<  "not a signal" << method.methodType();
        return -1;
    }

    int index = -1;
    const QMetaObject *metaObject = method.enclosingMetaObject();
    for (int i=0; i<=method.methodIndex(); i++) {
        if (metaObject->method(i).methodType() != QMetaMethod::Signal) {
            continue;
        }
        index++;
    }

    return index;
}

void beeCopterApplication::CompressedSignalList::add(const QMetaMethod &method)
{
    const QMetaObject *metaObject = method.enclosingMetaObject();
    const int signalIndex = _signalIndex(method);

    if (signalIndex != -1 && !contains(metaObject, signalIndex)) {
        _signalMap[method.enclosingMetaObject()].insert(signalIndex);
    }
}

void beeCopterApplication::CompressedSignalList::remove(const QMetaMethod &method)
{
    const int signalIndex = _signalIndex(method);
    const QMetaObject *const metaObject = method.enclosingMetaObject();

    if (signalIndex != -1 && _signalMap.contains(metaObject) && _signalMap[metaObject].contains(signalIndex)) {
        _signalMap[metaObject].remove(signalIndex);
        if (_signalMap[metaObject].count() == 0) {
            _signalMap.remove(metaObject);
        }
    }
}

bool beeCopterApplication::CompressedSignalList::contains(const QMetaObject *metaObject, int signalIndex)
{
    return _signalMap.contains(metaObject) && _signalMap[metaObject].contains(signalIndex);
}

void beeCopterApplication::addCompressedSignal(const QMetaMethod &method)
{
    _compressedSignals.add(method);
}

void beeCopterApplication::removeCompressedSignal(const QMetaMethod &method)
{
    _compressedSignals.remove(method);
}

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
bool beeCopterApplication::compressEvent(QEvent *event, QObject *receiver, QPostEventList *postedEvents)
{
    if (event->type() != QEvent::MetaCall) {
        return QApplication::compressEvent(event, receiver, postedEvents);
    }

    const QMetaCallEvent *mce = static_cast<QMetaCallEvent*>(event);
    if (!mce->sender() || !_compressedSignals.contains(mce->sender()->metaObject(), mce->signalId())) {
        return QApplication::compressEvent(event, receiver, postedEvents);
    }

    for (QPostEventList::iterator it = postedEvents->begin(); it != postedEvents->end(); ++it) {
        QPostEvent &cur = *it;
        if (cur.receiver != receiver || cur.event == 0 || cur.event->type() != event->type()) {
            continue;
        }
        const QMetaCallEvent *cur_mce = static_cast<QMetaCallEvent*>(cur.event);
        if (cur_mce->sender() != mce->sender() || cur_mce->signalId() != mce->signalId() || cur_mce->id() != mce->id()) {
            continue;
        }
        /* Keep The Newest Call */
        // We can't merely qSwap the existing posted event with the new one, since QEvent
        // keeps track of whether it has been posted. Deletion of a formerly posted event
        // takes the posted event list mutex and does a useless search of the posted event
        // list upon deletion. We thus clear the QEvent::posted flag before deletion.
        struct EventHelper : private QEvent {
            static void clearPostedFlag(QEvent * ev) {
                (&static_cast<EventHelper*>(ev)->t)[1] &= ~0x8001; // Hack to clear QEvent::posted
            }
        };
        EventHelper::clearPostedFlag(cur.event);
        delete cur.event;
        cur.event = event;
        return true;
    }

    return false;
}
QT_WARNING_POP

bool beeCopterApplication::event(QEvent *e)
{
    if (e->type() == QEvent::Quit) {
        // On OSX if the user selects Quit from the menu (or Command-Q) the ApplicationWindow does not signal closing. Instead you get a Quit event here only.
        // This in turn causes the standard beeCopter shutdown sequence to not run. So in this case we close the window ourselves such that the
        // signal is sent and the normal shutdown sequence runs.
        const bool forceClose = _mainRootWindow->property("_forceClose").toBool();
        qCDebug(beeCopterApplicationLog) << "Quit event" << forceClose;
        // forceClose
        //  true:   Standard beeCopter shutdown sequence is complete. Let the app quit normally by falling through to the base class processing.
        //  false:  beeCopter shutdown sequence has not been run yet. Don't let this event close the app yet. Close the main window to kick off the normal shutdown.
        if (!forceClose) {
            //
            _mainRootWindow->close();
            e->ignore();
            return true;
        }
    }

    return QApplication::event(e);
}

beeCopterImageProvider *beeCopterApplication::beeCopterImageProvider()
{
    return dynamic_cast<beeCopterImageProvider*>(_qmlAppEngine->imageProvider(_beeCopterImageProviderId));
}

void beeCopterApplication::shutdown()
{
    qCDebug(beeCopterApplicationLog) << "Exit";

    if (_videoManagerInitialized) {
        VideoManager::instance()->cleanup();
    }

    beeCopterCorePlugin::instance()->cleanup();

    // This is bad, but currently qobject inheritances are incorrect and cause crashes on exit without
    delete _qmlAppEngine;
}

QString beeCopterApplication::numberToString(quint64 number)
{
    return getCurrentLanguage().toString(number);
}

QString beeCopterApplication::bigSizeToString(quint64 size)
{
    QString result;
    const QLocale kLocale = getCurrentLanguage();
    if (size < 1024) {
        result = kLocale.toString(size) + "B";
    } else if (size < pow(1024, 2)) {
        result = kLocale.toString(static_cast<double>(size) / 1024.0, 'f', 1) + "KB";
    } else if (size < pow(1024, 3)) {
        result = kLocale.toString(static_cast<double>(size) / pow(1024, 2), 'f', 1) + "MB";
    } else if (size < pow(1024, 4)) {
        result = kLocale.toString(static_cast<double>(size) / pow(1024, 3), 'f', 1) + "GB";
    } else {
        result = kLocale.toString(static_cast<double>(size) / pow(1024, 4), 'f', 1) + "TB";
    }
    return result;
}

QString beeCopterApplication::bigSizeMBToString(quint64 size_MB)
{
    QString result;
    const QLocale kLocale = getCurrentLanguage();
    if (size_MB < 1024) {
        result = kLocale.toString(static_cast<double>(size_MB) , 'f', 0) + " MB";
    } else if(size_MB < pow(1024, 2)) {
        result = kLocale.toString(static_cast<double>(size_MB) / 1024.0, 'f', 1) + " GB";
    } else {
        result = kLocale.toString(static_cast<double>(size_MB) / pow(1024, 2), 'f', 2) + " TB";
    }
    return result;
}
