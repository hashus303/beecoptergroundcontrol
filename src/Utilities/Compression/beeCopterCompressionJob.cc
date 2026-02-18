#include "beeCopterCompressionJob.h"
#include "beeCopterCompression.h"
#include "beeCopterLoggingCategory.h"

#include <QtConcurrent/QtConcurrent>
#include <QtCore/QPromise>

beeCopter_LOGGING_CATEGORY(beeCopterCompressionJobLog, "Utilities.beeCopterCompressionJob")

// ============================================================================
// Construction / Destruction
// ============================================================================

beeCopterCompressionJob::beeCopterCompressionJob(QObject *parent)
    : QObject(parent)
    , _watcher(new QFutureWatcher<bool>(this))
{
    connect(_watcher, &QFutureWatcher<bool>::progressValueChanged,
            this, &beeCopterCompressionJob::_onProgressValueChanged);
    connect(_watcher, &QFutureWatcher<bool>::finished,
            this, &beeCopterCompressionJob::_onFutureFinished);
}

beeCopterCompressionJob::~beeCopterCompressionJob()
{
    cancel();
    if (_future.isRunning()) {
        _future.waitForFinished();
    }
}

// ============================================================================
// Static Async Methods
// ============================================================================

QFuture<bool> beeCopterCompressionJob::extractArchiveAsync(const QString &archivePath,
                                                      const QString &outputDirectoryPath,
                                                      qint64 maxBytes)
{
    const auto cancelRequested = std::make_shared<std::atomic_bool>(false);
    auto work = [archivePath, outputDirectoryPath, maxBytes](beeCopterCompression::ProgressCallback progress) {
        return beeCopterCompression::extractArchive(archivePath, outputDirectoryPath,
                                               beeCopterCompression::Format::Auto,
                                               progress, maxBytes);
    };

    return _runWithProgress(work, cancelRequested);
}

QFuture<bool> beeCopterCompressionJob::decompressFileAsync(const QString &inputPath,
                                                      const QString &outputPath,
                                                      qint64 maxBytes)
{
    const auto cancelRequested = std::make_shared<std::atomic_bool>(false);
    auto work = [inputPath, outputPath, maxBytes](beeCopterCompression::ProgressCallback progress) {
        return beeCopterCompression::decompressFile(inputPath, outputPath,
                                               beeCopterCompression::Format::Auto,
                                               progress, maxBytes);
    };

    return _runWithProgress(work, cancelRequested);
}

// ============================================================================
// Public Slots
// ============================================================================

void beeCopterCompressionJob::extractArchive(const QString &archivePath,
                                        const QString &outputDirectoryPath,
                                        qint64 maxBytes)
{
    auto work = [archivePath, outputDirectoryPath, maxBytes](beeCopterCompression::ProgressCallback progress) {
        return beeCopterCompression::extractArchive(archivePath, outputDirectoryPath,
                                               beeCopterCompression::Format::Auto,
                                               progress, maxBytes);
    };

    _startOperation(Operation::ExtractArchive, archivePath, outputDirectoryPath, work);
}

void beeCopterCompressionJob::extractArchiveAtomic(const QString &archivePath,
                                              const QString &outputDirectoryPath,
                                              qint64 maxBytes)
{
    auto work = [archivePath, outputDirectoryPath, maxBytes](beeCopterCompression::ProgressCallback progress) {
        return beeCopterCompression::extractArchiveAtomic(archivePath, outputDirectoryPath,
                                                     beeCopterCompression::Format::Auto,
                                                     progress, maxBytes);
    };

    _startOperation(Operation::ExtractArchiveAtomic, archivePath, outputDirectoryPath, work);
}

void beeCopterCompressionJob::decompressFile(const QString &inputPath,
                                        const QString &outputPath,
                                        qint64 maxBytes)
{
    auto work = [inputPath, outputPath, maxBytes](beeCopterCompression::ProgressCallback progress) {
        return beeCopterCompression::decompressFile(inputPath, outputPath,
                                               beeCopterCompression::Format::Auto,
                                               progress, maxBytes);
    };

    _startOperation(Operation::DecompressFile, inputPath, outputPath, work);
}

void beeCopterCompressionJob::extractFile(const QString &archivePath,
                                     const QString &fileName,
                                     const QString &outputPath)
{
    auto work = [archivePath, fileName, outputPath](beeCopterCompression::ProgressCallback) {
        return beeCopterCompression::extractFile(archivePath, fileName, outputPath);
    };

    _startOperation(Operation::ExtractFile, archivePath, outputPath, work);
}

void beeCopterCompressionJob::extractFiles(const QString &archivePath,
                                      const QStringList &fileNames,
                                      const QString &outputDirectoryPath)
{
    auto work = [archivePath, fileNames, outputDirectoryPath](beeCopterCompression::ProgressCallback) {
        return beeCopterCompression::extractFiles(archivePath, fileNames, outputDirectoryPath);
    };

    _startOperation(Operation::ExtractFiles, archivePath, outputDirectoryPath, work);
}

void beeCopterCompressionJob::cancel()
{
    if (!_running || !_future.isRunning()) {
        return;
    }

    qCDebug(beeCopterCompressionJobLog) << "Cancelling operation:" << static_cast<int>(_operation);

    if (_cancelRequested) {
        _cancelRequested->store(true, std::memory_order_release);
    }

    _future.cancel();
}

// ============================================================================
// Private Slots
// ============================================================================

void beeCopterCompressionJob::_onProgressValueChanged(int progressValue)
{
    _setProgress(static_cast<qreal>(progressValue) / 100.0);
}

void beeCopterCompressionJob::_onFutureFinished()
{
    bool success = false;
    QString error;
    const bool wasCancelled = _future.isCanceled()
                              || (_cancelRequested && _cancelRequested->load(std::memory_order_acquire));

    if (wasCancelled) {
        error = QStringLiteral("Operation cancelled");
        qCDebug(beeCopterCompressionJobLog) << "Operation cancelled:" << static_cast<int>(_operation);
    } else {
        try {
            success = _future.result();
            if (!success) {
                error = beeCopterCompression::lastErrorString();
            }
        } catch (const std::exception &e) {
            error = QString::fromUtf8(e.what());
        }
    }

    qCDebug(beeCopterCompressionJobLog) << "Operation finished:" << static_cast<int>(_operation)
                                   << "success:" << success
                                   << "error:" << error;

    if (!success && !error.isEmpty()) {
        _setErrorString(error);
    } else if (success) {
        _setErrorString(QString());
    }

    _setProgress(success ? 1.0 : _progress);
    _setRunning(false);
    _operation = Operation::None;
    _cancelRequested.reset();

    emit finished(success);
}

// ============================================================================
// Private Methods
// ============================================================================

void beeCopterCompressionJob::_startOperation(Operation op, const QString &source,
                                         const QString &output,
                                         WorkFunction work)
{
    if (_running) {
        qCWarning(beeCopterCompressionJobLog) << "Operation already in progress";
        return;
    }

    qCDebug(beeCopterCompressionJobLog) << "Starting operation:" << static_cast<int>(op)
                                   << "source:" << source << "output:" << output;

    _operation = op;

    // Update paths
    if (_sourcePath != source) {
        _sourcePath = source;
        emit sourcePathChanged(_sourcePath);
    }
    if (_outputPath != output) {
        _outputPath = output;
        emit outputPathChanged(_outputPath);
    }

    _setProgress(0.0);
    _setErrorString(QString());
    _setRunning(true);
    _cancelRequested = std::make_shared<std::atomic_bool>(false);

    // Create and start the future
    _future = _runWithProgress(std::move(work), _cancelRequested);
    _watcher->setFuture(_future);
}

QFuture<bool> beeCopterCompressionJob::_runWithProgress(WorkFunction work,
                                                  const std::shared_ptr<std::atomic_bool> &cancelRequested)
{
    // Use QPromise to create a QFuture with progress reporting
    return QtConcurrent::run([work = std::move(work), cancelRequested]() -> bool {
        QPromise<bool> promise;
        QFuture<bool> future = promise.future();

        promise.start();
        promise.setProgressRange(0, 100);

        // Progress callback that updates QPromise and checks for cancellation
        auto progressCallback = [&promise, cancelRequested](qint64 bytesProcessed, qint64 totalBytes) -> bool {
            if (promise.isCanceled()
                || (cancelRequested && cancelRequested->load(std::memory_order_acquire))) {
                return false;  // Signal cancellation to the work function
            }

            int progressValue = 0;
            if (totalBytes > 0) {
                progressValue = static_cast<int>((bytesProcessed * 100) / totalBytes);
            } else if (bytesProcessed > 0) {
                // Unknown total - asymptotic progress
                const double normalized = static_cast<double>(bytesProcessed) / 1048576.0;
                progressValue = static_cast<int>(50.0 * (1.0 - (1.0 / (1.0 + normalized))));
            }

            promise.setProgressValue(progressValue);
            return true;  // Continue
        };

        bool success = false;
        try {
            if (cancelRequested && cancelRequested->load(std::memory_order_acquire)) {
                success = false;
            } else {
                success = work(progressCallback);
            }
        } catch (const std::exception &e) {
            qCWarning(beeCopterCompressionJobLog) << "Exception during compression operation:" << e.what();
            success = false;
        }

        promise.setProgressValue(100);
        promise.addResult(success);
        promise.finish();

        return success;
    });
}

void beeCopterCompressionJob::_setProgress(qreal progress)
{
    if (!qFuzzyCompare(_progress, progress)) {
        _progress = progress;
        emit progressChanged(_progress);
    }
}

void beeCopterCompressionJob::_setRunning(bool running)
{
    if (_running != running) {
        _running = running;
        emit runningChanged(_running);
    }
}

void beeCopterCompressionJob::_setErrorString(const QString &error)
{
    if (_errorString != error) {
        _errorString = error;
        emit errorStringChanged(_errorString);
    }
}
