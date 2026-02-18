#pragma once

#include <QtCore/QElapsedTimer>
#include <QtCore/QLoggingCategory>
#include <QtCore/QMutex>
#include <QtCore/QQueue>
#include <QtCore/QString>
#include <QtCore/QThread>
#include <QtCore/QWaitCondition>

#include <memory>

Q_DECLARE_LOGGING_CATEGORY(beeCopterTileCacheWorkerLog)

class beeCopterMapTask;
class beeCopterTileCacheDatabase;

class beeCopterCacheWorker : public QThread
{
    Q_OBJECT

public:
    explicit beeCopterCacheWorker(QObject *parent = nullptr);
    ~beeCopterCacheWorker();

    void setDatabaseFile(const QString &path) { if (isRunning()) { return; } _databasePath = path; }

public slots:
    bool enqueueTask(beeCopterMapTask *task);
    void stop();

signals:
    void updateTotals(quint32 totaltiles, quint64 totalsize, quint32 defaulttiles, quint64 defaultsize);

protected:
    void run() final;

private:
    void _runTask(beeCopterMapTask *task);

    void _saveTile(beeCopterMapTask *task);
    void _getTile(beeCopterMapTask *task);
    void _getTileSets(beeCopterMapTask *task);
    void _createTileSet(beeCopterMapTask *task);
    void _getTileDownloadList(beeCopterMapTask *task);
    void _updateTileDownloadState(beeCopterMapTask *task);
    void _pruneCache(beeCopterMapTask *task);
    void _deleteTileSet(beeCopterMapTask *task);
    void _renameTileSet(beeCopterMapTask *task);
    void _resetCacheDatabase(beeCopterMapTask *task);
    void _importSets(beeCopterMapTask *task);
    void _exportSets(beeCopterMapTask *task);
    bool _testTask(beeCopterMapTask *task);
    void _emitTotals();

    std::unique_ptr<beeCopterTileCacheDatabase> _database;
    QMutex _taskQueueMutex;
    QQueue<beeCopterMapTask*> _taskQueue;
    QWaitCondition _waitc;
    QString _databasePath;
    QElapsedTimer _updateTimer;
    int _updateTimeout = kShortTimeoutMs;
    std::atomic_bool _dbValid = false;
    std::atomic_bool _stopRequested = false;

    static constexpr int kShortTimeoutMs = 2000;
    static constexpr int kLongTimeoutMs = 5000;
};
