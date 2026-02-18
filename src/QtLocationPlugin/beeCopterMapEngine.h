#pragma once

#include <QtCore/QLoggingCategory>
#include <QtCore/QObject>
#include <QtCore/QString>

Q_DECLARE_LOGGING_CATEGORY(beeCopterMapEngineLog)

class beeCopterMapTask;
class beeCopterCacheWorker;

class beeCopterMapEngine : public QObject
{
    Q_OBJECT

public:
    explicit beeCopterMapEngine(QObject *parent = nullptr);
    ~beeCopterMapEngine();

    void init(const QString &databasePath);
    bool addTask(beeCopterMapTask *task);

    static beeCopterMapEngine *instance();

signals:
    void updateTotals(quint32 totaltiles, quint64 totalsize, quint32 defaulttiles, quint64 defaultsize);

private slots:
    void _updateTotals(quint32 totaltiles, quint64 totalsize, quint32 defaulttiles, quint64 defaultsize);
    void _pruned() { m_pruning = false; }

private:
    beeCopterCacheWorker *m_worker = nullptr;
    bool m_pruning = false;
    std::atomic<bool> m_initialized = false;
};

extern beeCopterMapEngine *getbeeCopterMapEngine();
