#include "beeCopterLogging.h"
#include "AppSettings.h"
#include "beeCopterApplication.h"
#include "beeCopterLoggingCategory.h"
#include "SettingsManager.h"

#include <QtConcurrent/QtConcurrentRun>
#include <QtCore/QGlobalStatic>
#include <QtCore/QStringListModel>
#include <QtCore/QTextStream>

beeCopter_LOGGING_CATEGORY(beeCopterLoggingLog, "Utilities.beeCopterLogging")

Q_GLOBAL_STATIC(beeCopterLogging, _beeCopterLogging)

static QtMessageHandler defaultHandler = nullptr;

static void msgHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    // Call the previous handler FIRST to ensure QTest::ignoreMessage works correctly.
    // QTest's message filtering happens in the default handler, so we must call it
    // before any processing that might interfere with message matching.
    if (defaultHandler) {
        defaultHandler(type, context, msg);
    }

    // Format the message using Qt's pattern
    const QString message = qFormatLogMessage(type, context, msg);

    // Filter out Qt Quick internals
    if (beeCopterLogging::instance() && !QString(context.category).startsWith("qt.quick")) {
        beeCopterLogging::instance()->log(message);
    }
}

beeCopterLogging *beeCopterLogging::instance()
{
    return _beeCopterLogging();
}

beeCopterLogging::beeCopterLogging(QObject *parent)
    : QStringListModel(parent)
{
    qCDebug(beeCopterLoggingLog) << this;

    _flushTimer.setInterval(kFlushIntervalMSecs);
    _flushTimer.setSingleShot(false);
    (void) connect(&_flushTimer, &QTimer::timeout, this, &beeCopterLogging::_flushToDisk);
    _flushTimer.start();

    // Connect the emitLog signal to threadsafeLog slot
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    const Qt::ConnectionType conntype = Qt::QueuedConnection;
#else
    const Qt::ConnectionType conntype = Qt::AutoConnection;
#endif
    (void) connect(this, &beeCopterLogging::emitLog, this, &beeCopterLogging::_threadsafeLog, conntype);
}

beeCopterLogging::~beeCopterLogging()
{
    qCDebug(beeCopterLoggingLog) << this;
}

void beeCopterLogging::installHandler()
{
    // Define the format for qDebug/qWarning/etc output
    qSetMessagePattern(QStringLiteral("%{time process}%{if-warning} Warning:%{endif}%{if-critical} Critical:%{endif} %{message} - %{category} - (%{function}:%{line})"));

    // Install our custom handler
    defaultHandler = qInstallMessageHandler(msgHandler);
}

void beeCopterLogging::log(const QString &message)
{
    // Emit the signal so threadsafeLog runs in the correct thread
    if (!_ioError) {
        emit emitLog(message);
    }
}

void beeCopterLogging::_threadsafeLog(const QString &message)
{
    // Notify view of new row
    const int line = rowCount();
    (void) QStringListModel::insertRows(line, 1);
    (void) setData(index(line, 0), message, Qt::DisplayRole);

    // Trim old entries to cap memory usage
    static constexpr const int kMaxLogRows = kMaxLogFileSize / 100;
    if (rowCount() > kMaxLogRows) {
        const int removeCount = rowCount() - kMaxLogRows;
        beginRemoveRows(QModelIndex(), 0, removeCount - 1);
        (void) removeRows(0, removeCount);
        endRemoveRows();
    }

    // Queue for disk flush
    _pendingDiskWrites.append(message);
}

void beeCopterLogging::_rotateLogs()
{
    // Close the current log
    _logFile.close();

    // Full path without extension
    const QString basePath = _logFile.fileName();    // e.g. "/path/beeCopterConsole.log"
    const QFileInfo fileInfo(basePath);
    const QString dir = fileInfo.absolutePath();
    const QString name = fileInfo.baseName();        // "beeCopterConsole"
    const QString ext = fileInfo.completeSuffix();   // "log"

    // Rotate existing backups: beeCopterConsole.4.log → beeCopterConsole.5.log, …
    for (int i = kMaxBackupFiles - 1; i >= 1; --i) {
        const QString from = QStringLiteral("%1/%2.%3.%4").arg(dir, name).arg(i).arg(ext);
        const QString to = QStringLiteral("%1/%2.%3.%4").arg(dir, name).arg(i+1).arg(ext);
        if (QFile::exists(to)) {
            (void) QFile::remove(to);
        }
        if (QFile::exists(from)) {
            (void) QFile::rename(from, to);
        }
    }

    // Move the just‐closed log to “.1”
    const QString firstBackup = QStringLiteral("%1/%2.1.%3").arg(dir, name, ext);
    if (QFile::exists(firstBackup)) {
        (void) QFile::remove(firstBackup);
    }
    (void) QFile::rename(basePath, firstBackup);

    // Re‑open a fresh log file
    _logFile.setFileName(basePath);
    if (!_logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        _ioError = true;
        beeCopterApp()->showAppMessage(tr("Unable to reopen log file %1: %2").arg(_logFile.fileName(), _logFile.errorString()));
    }
}

void beeCopterLogging::_flushToDisk()
{
    if (_pendingDiskWrites.isEmpty() || _ioError) {
        return;
    }

    // Ensure log output enabled and file open
    if (!_logFile.isOpen()) {
        if (!beeCopterApp()->logOutput()) {
            _pendingDiskWrites.clear();
            return;
        }

        const QString saveDirPath = SettingsManager::instance()->appSettings()->crashSavePath();
        const QDir saveDir(saveDirPath);
        const QString saveFilePath = saveDir.absoluteFilePath("beeCopterConsole.log");

        _logFile.setFileName(saveFilePath);
        if (!_logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
            _ioError = true;
            beeCopterApp()->showAppMessage(tr("Open console log output file failed %1 : %2").arg(_logFile.fileName(), _logFile.errorString()));
            return;
        }
    }

    // Check size before writing
    if (_logFile.size() >= kMaxLogFileSize) {
        _rotateLogs();
    }

    // Write all pending lines
    QTextStream out(&_logFile);
    for (const QString &line : std::as_const(_pendingDiskWrites)) {
        out << line << '\n';
        if (out.status() != QTextStream::Ok) {
            _ioError = true;
            qCWarning(beeCopterLoggingLog) << "Error writing to log file:" << _logFile.errorString();
            break;
        }
    }
    (void) _logFile.flush();
    _pendingDiskWrites.clear();
}

void beeCopterLogging::writeMessages(const QString &destFile)
{
    // Snapshot current logs on GUI thread
    const QStringList logs = stringList();

    // Run the file write in a separate thread
    (void) QtConcurrent::run([this, destFile, logs]() {
        emit writeStarted();
        bool success = false;
        QSaveFile file(destFile);
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            for (const QString &line : logs) {
                out << line << '\n';
            }
            success = ((out.status() == QTextStream::Ok) && file.commit());
        } else {
            qCWarning(beeCopterLoggingLog) << "write failed:" << file.errorString();
        }
        emit writeFinished(success);
    });
}
