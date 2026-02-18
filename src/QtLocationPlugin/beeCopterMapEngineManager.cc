#include "beeCopterMapEngineManager.h"

#include <QtCore/QApplicationStatic>
#include <QtCore/QDir>
#include <QtCore/QDirIterator>
#include <QtCore/QRegularExpression>
#include <QtCore/QSettings>
#include <QtCore/QStorageInfo>
#include <QtCore/QTemporaryDir>
#include <QtQml/QQmlEngine>

#include "ElevationMapProvider.h"
#include "FlightMapSettings.h"
#include "beeCopterApplication.h"
#include "beeCopterCachedTileSet.h"
#include "beeCopterCompression.h"
#include "beeCopterCompressionJob.h"
#include "beeCopterLoggingCategory.h"
#include "beeCopterMapEngine.h"
#include "beeCopterMapUrlEngine.h"
#include "QGeoFileTileCachebeeCopter.h"
#include "QmlObjectListModel.h"
#include "SettingsManager.h"

using namespace Qt::StringLiterals;

beeCopter_LOGGING_CATEGORY(beeCopterMapEngineManagerLog, "QtLocationPlugin.beeCopterMapEngineManager")

Q_APPLICATION_STATIC(beeCopterMapEngineManager, _mapEngineManager);

beeCopterMapEngineManager *beeCopterMapEngineManager::instance()
{
    return _mapEngineManager();
}

beeCopterMapEngineManager::beeCopterMapEngineManager(QObject *parent)
    : QObject(parent)
    , _tileSets(new QmlObjectListModel(this))
{
    qCDebug(beeCopterMapEngineManagerLog) << this;

    (void) qmlRegisterUncreatableType<beeCopterMapEngineManager>("beeCopter.beeCopterMapEngineManager", 1, 0, "beeCopterMapEngineManager", "Reference only");

    (void) connect(getbeeCopterMapEngine(), &beeCopterMapEngine::updateTotals, this, &beeCopterMapEngineManager::_updateTotals, Qt::UniqueConnection);
}

beeCopterMapEngineManager::~beeCopterMapEngineManager()
{
    _tileSets->clear();

    qCDebug(beeCopterMapEngineManagerLog) << this;
}

void beeCopterMapEngineManager::updateForCurrentView(double lon0, double lat0, double lon1, double lat1, int minZoom, int maxZoom, const QString &mapName)
{
    _topleftLat = lat0;
    _topleftLon = lon0;
    _bottomRightLat = lat1;
    _bottomRightLon = lon1;
    _minZoom = minZoom;
    _maxZoom = maxZoom;

    _imageSet.clear();
    _elevationSet.clear();

    for (int z = minZoom; z <= maxZoom; z++) {
        const beeCopterTileSet set = UrlFactory::getTileCount(z, lon0, lat0, lon1, lat1, mapName);
        _imageSet += set;
    }

    if (_fetchElevation) {
        const QString elevationProviderName = SettingsManager::instance()->flightMapSettings()->elevationMapProvider()->rawValue().toString();
        const beeCopterTileSet set = UrlFactory::getTileCount(1, lon0, lat0, lon1, lat1, elevationProviderName);
        _elevationSet += set;
    }

    emit tileCountChanged();
    emit tileSizeChanged();

    qCDebug(beeCopterMapEngineManagerLog) << lat0 << lon0 << lat1 << lon1 << minZoom << maxZoom;
}

QString beeCopterMapEngineManager::tileCountStr() const
{
    return beeCopterApp()->numberToString(_imageSet.tileCount + _elevationSet.tileCount);
}

QString beeCopterMapEngineManager::tileSizeStr() const
{
    return beeCopterApp()->bigSizeToString(_imageSet.tileSize + _elevationSet.tileSize);
}

void beeCopterMapEngineManager::loadTileSets()
{
    if (_tileSets->count() > 0) {
        _tileSets->clear();
        emit tileSetsChanged();
    }

    beeCopterFetchTileSetTask *task = new beeCopterFetchTileSetTask();
    (void) connect(task, &beeCopterFetchTileSetTask::tileSetFetched, this, &beeCopterMapEngineManager::_tileSetFetched);
    (void) connect(task, &beeCopterMapTask::error, this, &beeCopterMapEngineManager::taskError);
    if (!getbeeCopterMapEngine()->addTask(task)) {
        task->deleteLater();
    }
}

void beeCopterMapEngineManager::_tileSetFetched(beeCopterCachedTileSet *tileSet)
{
    if (tileSet->type() == QStringLiteral("Invalid")) {
        tileSet->setMapTypeStr(QStringLiteral("Various"));
    }

    tileSet->setManager(this);
    _tileSets->append(tileSet);
    emit tileSetsChanged();
}

void beeCopterMapEngineManager::startDownload(const QString &name, const QString &mapType)
{
    if (_imageSet.tileSize > 0) {
        beeCopterCachedTileSet* const set = new beeCopterCachedTileSet(name);
        set->setMapTypeStr(mapType);
        set->setTopleftLat(_topleftLat);
        set->setTopleftLon(_topleftLon);
        set->setBottomRightLat(_bottomRightLat);
        set->setBottomRightLon(_bottomRightLon);
        set->setMinZoom(_minZoom);
        set->setMaxZoom(_maxZoom);
        set->setTotalTileSize(_imageSet.tileSize);
        set->setTotalTileCount(static_cast<quint32>(_imageSet.tileCount));
        set->setType(mapType);

        beeCopterCreateTileSetTask *task = new beeCopterCreateTileSetTask(set);
        (void) connect(task, &beeCopterCreateTileSetTask::tileSetSaved, this, &beeCopterMapEngineManager::_tileSetSaved);
        (void) connect(task, &beeCopterMapTask::error, this, &beeCopterMapEngineManager::taskError);
        if (!getbeeCopterMapEngine()->addTask(task)) {
            task->deleteLater();
        }
    } else {
        qCWarning(beeCopterMapEngineManagerLog) << "No Tiles to save";
    }

    const int mapid = UrlFactory::getQtMapIdFromProviderType(mapType);
    if (_fetchElevation && !UrlFactory::isElevation(mapid)) {
        beeCopterCachedTileSet* const set = new beeCopterCachedTileSet(name + QStringLiteral(" Elevation"));
        const QString elevationProviderName = SettingsManager::instance()->flightMapSettings()->elevationMapProvider()->rawValue().toString();
        set->setMapTypeStr(elevationProviderName);
        set->setTopleftLat(_topleftLat);
        set->setTopleftLon(_topleftLon);
        set->setBottomRightLat(_bottomRightLat);
        set->setBottomRightLon(_bottomRightLon);
        set->setMinZoom(1);
        set->setMaxZoom(1);
        set->setTotalTileSize(_elevationSet.tileSize);
        set->setTotalTileCount(static_cast<quint32>(_elevationSet.tileCount));
        set->setType(elevationProviderName);

        beeCopterCreateTileSetTask *task = new beeCopterCreateTileSetTask(set);
        (void) connect(task, &beeCopterCreateTileSetTask::tileSetSaved, this, &beeCopterMapEngineManager::_tileSetSaved);
        (void) connect(task, &beeCopterMapTask::error, this, &beeCopterMapEngineManager::taskError);
        if (!getbeeCopterMapEngine()->addTask(task)) {
            task->deleteLater();
        }
    } else {
        qCWarning(beeCopterMapEngineManagerLog) << "No Tiles to save";
    }
}

void beeCopterMapEngineManager::_tileSetSaved(beeCopterCachedTileSet *set)
{
    qCDebug(beeCopterMapEngineManagerLog) << "New tile set saved (" << set->name() << "). Starting download...";

    _tileSets->append(set);
    emit tileSetsChanged();
    set->createDownloadTask();
}

void beeCopterMapEngineManager::saveSetting(const QString &key, const QString &value)
{
    QSettings settings;
    settings.beginGroup(kQmlOfflineMapKeyName);
    settings.setValue(key, value);
}

QString beeCopterMapEngineManager::loadSetting(const QString &key, const QString &defaultValue)
{
    QSettings settings;
    settings.beginGroup(kQmlOfflineMapKeyName);
    return settings.value(key, defaultValue).toString();
}

QStringList beeCopterMapEngineManager::mapTypeList(const QString &provider)
{
    QStringList mapStringList = mapList();
    mapStringList = mapStringList.filter(QRegularExpression(provider));

    static const QRegularExpression providerType = QRegularExpression(uR"(^([^\ ]*) (.*)$)"_s);
    (void) mapStringList.replaceInStrings(providerType, "\\2");
    (void) mapStringList.removeDuplicates();

    return mapStringList;
}

void beeCopterMapEngineManager::deleteTileSet(beeCopterCachedTileSet *tileSet)
{
    qCDebug(beeCopterMapEngineManagerLog) << "Deleting tile set" << tileSet->name();

    if (tileSet->defaultSet()) {
        for (qsizetype i = 0; i < _tileSets->count(); i++ ) {
            beeCopterCachedTileSet* const set = qobject_cast<beeCopterCachedTileSet*>(_tileSets->get(i));
            if (set) {
                set->setDeleting(true);
            }
        }

        beeCopterResetTask *task = new beeCopterResetTask();
        (void) connect(task, &beeCopterResetTask::resetCompleted, this, &beeCopterMapEngineManager::_resetCompleted);
        (void) connect(task, &beeCopterMapTask::error, this, &beeCopterMapEngineManager::taskError);
        if (!getbeeCopterMapEngine()->addTask(task)) {
            task->deleteLater();
        }
    } else {
        tileSet->setDeleting(true);

        beeCopterDeleteTileSetTask *task = new beeCopterDeleteTileSetTask(tileSet->id());
        (void) connect(task, &beeCopterDeleteTileSetTask::tileSetDeleted, this, &beeCopterMapEngineManager::_tileSetDeleted);
        (void) connect(task, &beeCopterMapTask::error, this, &beeCopterMapEngineManager::taskError);
        if (!getbeeCopterMapEngine()->addTask(task)) {
            task->deleteLater();
        }
    }
}

void beeCopterMapEngineManager::renameTileSet(beeCopterCachedTileSet *tileSet, const QString &newName)
{
    int idx = 1;
    QString name = newName;
    while (findName(name)) {
        name = QString("%1 (%2)").arg(newName).arg(idx++);
    }

    qCDebug(beeCopterMapEngineManagerLog) << "Renaming tile set" << tileSet->name() << "to" << name;
    tileSet->setName(name);
    emit tileSet->nameChanged();

    beeCopterRenameTileSetTask *task = new beeCopterRenameTileSetTask(tileSet->id(), name);
    (void) connect(task, &beeCopterMapTask::error, this, &beeCopterMapEngineManager::taskError);
    if (!getbeeCopterMapEngine()->addTask(task)) {
        task->deleteLater();
    }
}

void beeCopterMapEngineManager::_tileSetDeleted(quint64 setID)
{
    for (qsizetype i = 0; i < _tileSets->count(); i++ ) {
        beeCopterCachedTileSet *set = qobject_cast<beeCopterCachedTileSet*>(_tileSets->get(i));
        if (set && (set->id() == setID)) {
            (void) _tileSets->removeAt(i);
            delete set;
            emit tileSetsChanged();
            break;
        }
    }
}

void beeCopterMapEngineManager::taskError(beeCopterMapTask::TaskType type, const QString &error)
{
    QString task;
    switch (type) {
    case beeCopterMapTask::TaskType::taskFetchTileSets:
        task = QStringLiteral("Fetch Tile Set");
        break;
    case beeCopterMapTask::TaskType::taskCreateTileSet:
        task = QStringLiteral("Create Tile Set");
        break;
    case beeCopterMapTask::TaskType::taskGetTileDownloadList:
        task = QStringLiteral("Get Tile Download List");
        break;
    case beeCopterMapTask::TaskType::taskUpdateTileDownloadState:
        task = QStringLiteral("Update Tile Download Status");
        break;
    case beeCopterMapTask::TaskType::taskDeleteTileSet:
        task = QStringLiteral("Delete Tile Set");
        break;
    case beeCopterMapTask::TaskType::taskReset:
        task = QStringLiteral("Reset Tile Sets");
        break;
    case beeCopterMapTask::TaskType::taskExport:
        task = QStringLiteral("Export Tile Sets");
        break;
    default:
        task = QStringLiteral("Database Error");
        break;
    }

    QString serror = QStringLiteral("Error in task: ") + task;
    serror += QStringLiteral("\nError description:\n");
    serror += error;

    setErrorMessage(serror);

    qCWarning(beeCopterMapEngineManagerLog) << serror;
}

void beeCopterMapEngineManager::_updateTotals(quint32 totaltiles, quint64 totalsize, quint32 defaulttiles, quint64 defaultsize)
{
    for (qsizetype i = 0; i < _tileSets->count(); i++) {
        beeCopterCachedTileSet* const set = qobject_cast<beeCopterCachedTileSet*>(_tileSets->get(i));
        if (set && set->defaultSet()) {
            set->setSavedTileSize(totalsize);
            set->setSavedTileCount(totaltiles);
            set->setTotalTileCount(defaulttiles);
            set->setTotalTileSize(defaultsize);
            return;
        }
    }
}

bool beeCopterMapEngineManager::findName(const QString &name) const
{
    for (qsizetype i = 0; i < _tileSets->count(); i++) {
        const beeCopterCachedTileSet* const set = qobject_cast<const beeCopterCachedTileSet*>(_tileSets->get(i));
        if (set && (set->name() == name)) {
            return true;
        }
    }

    return false;
}

void beeCopterMapEngineManager::selectAll()
{
    for (qsizetype i = 0; i < _tileSets->count(); i++) {
        beeCopterCachedTileSet* const set = qobject_cast<beeCopterCachedTileSet*>(_tileSets->get(i));
        if (set) {
            set->setSelected(true);
        }
    }
}

void beeCopterMapEngineManager::selectNone()
{
    for (qsizetype i = 0; i < _tileSets->count(); i++) {
        beeCopterCachedTileSet* const set = qobject_cast<beeCopterCachedTileSet*>(_tileSets->get(i));
        if (set) {
            set->setSelected(false);
        }
    }
}

int beeCopterMapEngineManager::selectedCount() const
{
    int count = 0;

    for (qsizetype i = 0; i < _tileSets->count(); i++) {
        const beeCopterCachedTileSet* const set = qobject_cast<const beeCopterCachedTileSet*>(_tileSets->get(i));
        if (set && set->selected()) {
            count++;
        }
    }

    return count;
}

bool beeCopterMapEngineManager::importSets(const QString &path)
{
    setImportAction(ImportAction::ActionNone);

    if (path.isEmpty()) {
        return false;
    }

    setImportAction(ImportAction::ActionImporting);

    beeCopterImportTileTask *task = new beeCopterImportTileTask(path, _importReplace);
    (void) connect(task, &beeCopterImportTileTask::actionCompleted, this, &beeCopterMapEngineManager::_actionCompleted);
    (void) connect(task, &beeCopterImportTileTask::actionProgress, this, &beeCopterMapEngineManager::_actionProgressHandler);
    (void) connect(task, &beeCopterMapTask::error, this, &beeCopterMapEngineManager::taskError);
    if (!getbeeCopterMapEngine()->addTask(task)) {
        task->deleteLater();
        return false;
    }

    return true;
}

bool beeCopterMapEngineManager::exportSets(const QString &path)
{
    setImportAction(ImportAction::ActionNone);

    if (path.isEmpty()) {
        return false;
    }

    QList<TileSetRecord> records;

    for (qsizetype i = 0; i < _tileSets->count(); i++) {
        beeCopterCachedTileSet* const set = qobject_cast<beeCopterCachedTileSet*>(_tileSets->get(i));
        if (set && set->selected()) {
            TileSetRecord rec;
            rec.setID = set->id();
            rec.name = set->name();
            rec.mapTypeStr = set->mapTypeStr();
            rec.topleftLat = set->topleftLat();
            rec.topleftLon = set->topleftLon();
            rec.bottomRightLat = set->bottomRightLat();
            rec.bottomRightLon = set->bottomRightLon();
            rec.minZoom = set->minZoom();
            rec.maxZoom = set->maxZoom();
            rec.type = UrlFactory::getQtMapIdFromProviderType(set->type());
            rec.numTiles = set->totalTileCount();
            rec.defaultSet = set->defaultSet();
            rec.date = set->creationDate().toSecsSinceEpoch();
            records.append(rec);
        }
    }

    if (records.isEmpty()) {
        return false;
    }

    setImportAction(ImportAction::ActionExporting);

    beeCopterExportTileTask *task = new beeCopterExportTileTask(records, path);
    (void) connect(task, &beeCopterExportTileTask::actionCompleted, this, &beeCopterMapEngineManager::_actionCompleted);
    (void) connect(task, &beeCopterExportTileTask::actionProgress, this, &beeCopterMapEngineManager::_actionProgressHandler);
    (void) connect(task, &beeCopterMapTask::error, this, &beeCopterMapEngineManager::taskError);
    if (!getbeeCopterMapEngine()->addTask(task)) {
        task->deleteLater();
        return false;
    }

    return true;
}

void beeCopterMapEngineManager::_actionCompleted()
{
    const ImportAction oldState = _importAction;
    setImportAction(ImportAction::ActionDone);

    if (oldState == ImportAction::ActionImporting) {
        loadTileSets();
    }
}

QString beeCopterMapEngineManager::getUniqueName() const
{
    int count = 1;
    while (true) {
        const QString name = QStringLiteral("Tile Set ") + QString::asprintf("%03d", count++);
        if (!findName(name)) {
            return name;
        }
    }
}

QStringList beeCopterMapEngineManager::mapList()
{
    return UrlFactory::getProviderTypes();
}

QStringList beeCopterMapEngineManager::mapProviderList()
{
    QStringList mapStringList = mapList();
    const QStringList elevationStringList = elevationProviderList();
    for (const QString &elevationProviderName : elevationStringList) {
        (void) mapStringList.removeAll(elevationProviderName);
    }

    static const QRegularExpression providerType = QRegularExpression(uR"(^([^\ ]*) (.*)$)"_s);
    (void) mapStringList.replaceInStrings(providerType, "\\1");
    (void) mapStringList.removeDuplicates();

    return mapStringList;
}

QStringList beeCopterMapEngineManager::elevationProviderList()
{
    return UrlFactory::getElevationProviderTypes();
}

bool beeCopterMapEngineManager::importArchive(const QString &archivePath)
{
    if (archivePath.isEmpty()) {
        setErrorMessage(tr("No archive path specified"));
        return false;
    }

    if (!QFile::exists(archivePath)) {
        setErrorMessage(tr("Archive file not found: %1").arg(archivePath));
        return false;
    }

    if (!beeCopterCompression::isArchiveFile(archivePath)) {
        setErrorMessage(tr("Not a supported archive format: %1").arg(archivePath));
        return false;
    }

    if (_importAction == ImportAction::ActionImporting) {
        setErrorMessage(tr("Import already in progress"));
        return false;
    }

    const QString tempPath = QDir::temp().filePath(QStringLiteral("beeCopter_tiles_") + QString::number(QDateTime::currentMSecsSinceEpoch()));
    if (!QDir().mkpath(tempPath)) {
        setErrorMessage(tr("Could not create temporary directory"));
        return false;
    }

    _extractionOutputDir = tempPath;

    if (_extractionJob == nullptr) {
        _extractionJob = new beeCopterCompressionJob(this);
        connect(_extractionJob, &beeCopterCompressionJob::progressChanged,
                this, &beeCopterMapEngineManager::_handleExtractionProgress);
        connect(_extractionJob, &beeCopterCompressionJob::finished,
                this, &beeCopterMapEngineManager::_handleExtractionFinished);
    }

    setImportAction(ImportAction::ActionImporting);
    setActionProgress(0);

    _extractionJob->extractArchive(archivePath, tempPath);
    return true;
}

void beeCopterMapEngineManager::_handleExtractionProgress(qreal progress)
{
    setActionProgress(static_cast<int>(progress * 50.0));
}

void beeCopterMapEngineManager::_handleExtractionFinished(bool success)
{
    if (!success) {
        const QString error = _extractionJob != nullptr ? _extractionJob->errorString() : tr("Extraction failed");
        setErrorMessage(error);
        setImportAction(ImportAction::ActionDone);
        QDir(_extractionOutputDir).removeRecursively();
        _extractionOutputDir.clear();
        return;
    }

    QString dbPath;
    QDirIterator it(_extractionOutputDir, {QStringLiteral("*.db"), QStringLiteral("*.sqlite")},
                    QDir::Files, QDirIterator::Subdirectories);
    if (it.hasNext()) {
        dbPath = it.next();
    }

    if (dbPath.isEmpty()) {
        setErrorMessage(tr("No tile database found in archive"));
        setImportAction(ImportAction::ActionDone);
        QDir(_extractionOutputDir).removeRecursively();
        _extractionOutputDir.clear();
        return;
    }

    qCDebug(beeCopterMapEngineManagerLog) << "Found tile database:" << dbPath;

    beeCopterImportTileTask *task = new beeCopterImportTileTask(dbPath, _importReplace);
    (void) connect(task, &beeCopterImportTileTask::actionCompleted, this, [this]() {
        _actionCompleted();
        QDir(_extractionOutputDir).removeRecursively();
        _extractionOutputDir.clear();
    });
    (void) connect(task, &beeCopterImportTileTask::actionProgress, this, [this](int percentage) {
        setActionProgress(50 + (percentage / 2));
    });
    (void) connect(task, &beeCopterMapTask::error, this, &beeCopterMapEngineManager::taskError);
    if (!getbeeCopterMapEngine()->addTask(task)) {
        task->deleteLater();
        setErrorMessage(tr("Failed to start import task"));
        setImportAction(ImportAction::ActionDone);
        QDir(_extractionOutputDir).removeRecursively();
        _extractionOutputDir.clear();
    }
}
