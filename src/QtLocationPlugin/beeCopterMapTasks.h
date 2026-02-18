#pragma once

#include <QtCore/QObject>
#include <QtCore/QQueue>
#include <QtCore/QString>

#include "beeCopterCacheTile.h"
#include "beeCopterCachedTileSet.h"
#include "beeCopterTileCacheTypes.h"
#include "beeCopterTile.h"

class beeCopterMapTask : public QObject
{
    Q_OBJECT

public:
    enum class TaskType {
        taskInit,
        taskCacheTile,
        taskFetchTile,
        taskFetchTileSets,
        taskCreateTileSet,
        taskGetTileDownloadList,
        taskUpdateTileDownloadState,
        taskDeleteTileSet,
        taskRenameTileSet,
        taskPruneCache,
        taskReset,
        taskExport,
        taskImport
    };
    Q_ENUM(TaskType);

    explicit beeCopterMapTask(TaskType type, QObject *parent = nullptr)
        : QObject(parent)
        , m_type(type)
    {}
    virtual ~beeCopterMapTask() = default;

    TaskType type() const { return m_type; }

    void setError(const QString &errorString = QString())
    {
        emit error(m_type, errorString);
    }

signals:
    void error(beeCopterMapTask::TaskType type, const QString &errorString);

private:
    const TaskType m_type = TaskType::taskInit;
};

//-----------------------------------------------------------------------------

class beeCopterFetchTileSetTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    explicit beeCopterFetchTileSetTask(QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskFetchTileSets, parent)
    {}
    ~beeCopterFetchTileSetTask() = default;

    void setTileSetFetched(beeCopterCachedTileSet *tileSet)
    {
        emit tileSetFetched(tileSet);
    }

signals:
    void tileSetFetched(beeCopterCachedTileSet *tileSet);
};

//-----------------------------------------------------------------------------

class beeCopterCreateTileSetTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    explicit beeCopterCreateTileSetTask(beeCopterCachedTileSet *tileSet, QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskCreateTileSet, parent)
        , m_tileSet(tileSet)
        , m_saved(false)
    {}
    ~beeCopterCreateTileSetTask()
    {
        if (!m_saved) {
            delete m_tileSet;
        }
    }

    beeCopterCachedTileSet *tileSet() { return m_tileSet; }

    void setTileSetSaved()
    {
        m_saved = true;
        emit tileSetSaved(m_tileSet);
    }

signals:
    void tileSetSaved(beeCopterCachedTileSet *tileSet);

private:
    beeCopterCachedTileSet* const m_tileSet = nullptr;
    bool m_saved = false;
};

//-----------------------------------------------------------------------------

class beeCopterFetchTileTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    explicit beeCopterFetchTileTask(const QString &hash, QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskFetchTile, parent)
        , m_hash(hash)
    {}
    ~beeCopterFetchTileTask() = default;

    void setTileFetched(beeCopterCacheTile *tile)
    {
        emit tileFetched(tile);
    }

    QString hash() const { return m_hash; }

signals:
    void tileFetched(beeCopterCacheTile *tile);

private:
    const QString m_hash;
};

//-----------------------------------------------------------------------------

class beeCopterSaveTileTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    explicit beeCopterSaveTileTask(beeCopterCacheTile *tile, QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskCacheTile, parent)
        , m_tile(tile)
    {}
    ~beeCopterSaveTileTask()
    {
        delete m_tile;
    }

    const beeCopterCacheTile *tile() const { return m_tile; }
    beeCopterCacheTile *tile() { return m_tile; }

private:
    beeCopterCacheTile* const m_tile = nullptr;
};

//-----------------------------------------------------------------------------

class beeCopterGetTileDownloadListTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    beeCopterGetTileDownloadListTask(quint64 setID, int count, QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskGetTileDownloadList, parent)
        , m_setID(setID)
        , m_count(count)
    {}
    ~beeCopterGetTileDownloadListTask() = default;

    quint64 setID() const { return m_setID; }
    int count() const { return m_count; }

    void setTileListFetched(const QQueue<beeCopterTile*> &tiles)
    {
        emit tileListFetched(tiles);
    }

signals:
    void tileListFetched(QQueue<beeCopterTile*> tiles);

private:
    const quint64 m_setID = 0;
    const int m_count = 0;
};

//-----------------------------------------------------------------------------

class beeCopterUpdateTileDownloadStateTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    beeCopterUpdateTileDownloadStateTask(quint64 setID, beeCopterTile::TileState state, const QString &hash, QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskUpdateTileDownloadState, parent)
        , m_setID(setID)
        , m_state(state)
        , m_hash(hash)
    {}
    ~beeCopterUpdateTileDownloadStateTask() = default;

    QString hash() const { return m_hash; }
    quint64 setID() const { return m_setID; }
    beeCopterTile::TileState state() const { return m_state; }

private:
    const quint64 m_setID = 0;
    const beeCopterTile::TileState m_state = beeCopterTile::StatePending;
    const QString m_hash;
};

//-----------------------------------------------------------------------------

class beeCopterDeleteTileSetTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    explicit beeCopterDeleteTileSetTask(quint64 setID, QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskDeleteTileSet, parent)
        , m_setID(setID)
    {}
    ~beeCopterDeleteTileSetTask() = default;

    quint64 setID() const { return m_setID; }

    void setTileSetDeleted()
    {
        emit tileSetDeleted(m_setID);
    }

signals:
    void tileSetDeleted(quint64 setID);

private:
    const quint64 m_setID = 0;
};

//-----------------------------------------------------------------------------

class beeCopterRenameTileSetTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    beeCopterRenameTileSetTask(quint64 setID, const QString &newName, QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskRenameTileSet, parent)
        , m_setID(setID)
        , m_newName(newName)
    {}
    ~beeCopterRenameTileSetTask() = default;

    quint64 setID() const { return m_setID; }
    QString newName() const { return m_newName; }

private:
    const quint64 m_setID = 0;
    const QString m_newName;
};

//-----------------------------------------------------------------------------

class beeCopterPruneCacheTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    explicit beeCopterPruneCacheTask(quint64 amount, QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskPruneCache, parent)
        , m_amount(amount)
    {}
    ~beeCopterPruneCacheTask() = default;

    quint64 amount() const { return m_amount; }

    void setPruned()
    {
        emit pruned();
    }

signals:
    void pruned();

private:
    const quint64 m_amount = 0;
};

//-----------------------------------------------------------------------------

class beeCopterResetTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    explicit beeCopterResetTask(QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskReset, parent)
    {}
    ~beeCopterResetTask() = default;

    void setResetCompleted()
    {
        emit resetCompleted();
    }

signals:
    void resetCompleted();
};

//-----------------------------------------------------------------------------

class beeCopterExportTileTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    explicit beeCopterExportTileTask(const QList<TileSetRecord> &sets, const QString &path, QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskExport, parent)
        , m_sets(sets)
        , m_path(path)
    {}
    ~beeCopterExportTileTask() = default;

    const QList<TileSetRecord> &sets() const { return m_sets; }
    QString path() const { return m_path; }

    void setExportCompleted()
    {
        emit actionCompleted();
    }

    void setProgress(int percentage)
    {
        emit actionProgress(percentage);
    }

signals:
    void actionCompleted();
    void actionProgress(int percentage);

private:
    const QList<TileSetRecord> m_sets;
    const QString m_path;
};

//-----------------------------------------------------------------------------

class beeCopterImportTileTask : public beeCopterMapTask
{
    Q_OBJECT

public:
    beeCopterImportTileTask(const QString &path, bool replace, QObject *parent = nullptr)
        : beeCopterMapTask(TaskType::taskImport, parent)
        , m_path(path)
        , m_replace(replace)
    {}
    ~beeCopterImportTileTask() = default;

    QString path() const { return m_path; }
    bool replace() const { return m_replace; }
    int progress() const { return m_progress; }

    void setImportCompleted()
    {
        emit actionCompleted();
    }

    void setProgress(int percentage)
    {
        m_progress = percentage;
        emit actionProgress(percentage);
    }

signals:
    void actionCompleted();
    void actionProgress(int percentage);

private:
    const QString m_path;
    const bool m_replace = false;
    int m_progress = 0;
};

//-----------------------------------------------------------------------------
