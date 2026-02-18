#include "beeCopterArchiveWatcher.h"
#include "beeCopterCompressionJob.h"
#include "beeCopterLoggingCategory.h"

#include <QtCore/QDir>
#include <QtCore/QFileInfo>

beeCopter_LOGGING_CATEGORY(beeCopterArchiveWatcherLog, "Utilities.beeCopterArchiveWatcher")

// ============================================================================
// Construction / Destruction
// ============================================================================

beeCopterArchiveWatcher::beeCopterArchiveWatcher(QObject *parent)
    : QObject(parent)
    , _fileWatcher(new beeCopterFileWatcher(this))
{
    _fileWatcher->setDebounceDelay(500);  // Longer debounce for file copy operations

    connect(_fileWatcher, &beeCopterFileWatcher::directoryChanged,
            this, &beeCopterArchiveWatcher::_onDirectoryChanged);
}

beeCopterArchiveWatcher::~beeCopterArchiveWatcher()
{
    if (_extractionJob != nullptr && _extractionJob->isRunning()) {
        _cancelPending = true;
        _extractionJob->cancel();
    }
}

// ============================================================================
// Configuration
// ============================================================================

void beeCopterArchiveWatcher::setFilterMode(FilterMode mode)
{
    _filterMode = mode;
}

void beeCopterArchiveWatcher::setAutoDecompress(bool enable)
{
    if (_autoDecompress != enable) {
        _autoDecompress = enable;
        emit autoDecompressChanged(_autoDecompress);
    }
}

void beeCopterArchiveWatcher::setOutputDirectory(const QString &directory)
{
    if (_outputDirectory != directory) {
        _outputDirectory = directory;
        emit outputDirectoryChanged(_outputDirectory);
    }
}

void beeCopterArchiveWatcher::setRemoveAfterExtraction(bool remove)
{
    _removeAfterExtraction = remove;
}

void beeCopterArchiveWatcher::setDebounceDelay(int milliseconds)
{
    _fileWatcher->setDebounceDelay(milliseconds);
}

int beeCopterArchiveWatcher::debounceDelay() const
{
    return _fileWatcher->debounceDelay();
}

// ============================================================================
// Directory Watching
// ============================================================================

bool beeCopterArchiveWatcher::watchDirectory(const QString &directoryPath)
{
    if (directoryPath.isEmpty()) {
        qCWarning(beeCopterArchiveWatcherLog) << "watchDirectory: empty path";
        return false;
    }

    const QString canonicalPath = QFileInfo(directoryPath).absoluteFilePath();

    if (!QFileInfo(canonicalPath).isDir()) {
        qCWarning(beeCopterArchiveWatcherLog) << "watchDirectory: not a directory:" << directoryPath;
        return false;
    }

    // Initialize known files for this directory
    if (!_knownFiles.contains(canonicalPath)) {
        QDir dir(canonicalPath);
        const QStringList entries = dir.entryList(QDir::Files);
        QSet<QString> fileSet;
        for (const QString &entry : entries) {
            fileSet.insert(dir.absoluteFilePath(entry));
        }
        _knownFiles[canonicalPath] = fileSet;
        qCDebug(beeCopterArchiveWatcherLog) << "Initialized" << fileSet.size() << "known files in" << canonicalPath;
    }

    if (_fileWatcher->watchDirectory(canonicalPath, nullptr)) {
        qCDebug(beeCopterArchiveWatcherLog) << "Watching directory for archives:" << canonicalPath;
        return true;
    }

    return false;
}

bool beeCopterArchiveWatcher::unwatchDirectory(const QString &directoryPath)
{
    const QString canonicalPath = QFileInfo(directoryPath).absoluteFilePath();
    _knownFiles.remove(canonicalPath);
    return _fileWatcher->unwatchDirectory(canonicalPath);
}

QStringList beeCopterArchiveWatcher::watchedDirectories() const
{
    return _fileWatcher->watchedDirectories();
}

void beeCopterArchiveWatcher::clear()
{
    _fileWatcher->clear();
    _knownFiles.clear();
    _pendingExtractions.clear();
    _currentArchive.clear();
    _setExtracting(false);
    _setProgress(0.0);

    if (_extractionJob) {
        if (_extractionJob->isRunning()) {
            _cancelPending = true;
            _extractionJob->cancel();
        }
    }
}

// ============================================================================
// Manual Operations
// ============================================================================

QStringList beeCopterArchiveWatcher::scanDirectory(const QString &directoryPath) const
{
    QStringList archives;

    QDir dir(directoryPath);
    if (!dir.exists()) {
        return archives;
    }

    const QStringList entries = dir.entryList(QDir::Files);
    for (const QString &entry : entries) {
        const QString fullPath = dir.absoluteFilePath(entry);
        if (_isWatchedFormat(fullPath)) {
            archives.append(fullPath);
        }
    }

    return archives;
}

void beeCopterArchiveWatcher::cancelExtraction()
{
    if (_extractionJob != nullptr && _extractionJob->isRunning()) {
        qCDebug(beeCopterArchiveWatcherLog) << "Cancelling extraction";
        _cancelPending = true;
        _extractionJob->cancel();
    }
    _pendingExtractions.clear();
    _currentArchive.clear();
    _setExtracting(false);
    _setProgress(0.0);
}

// ============================================================================
// Private Slots
// ============================================================================

void beeCopterArchiveWatcher::_onDirectoryChanged(const QString &path)
{
    qCDebug(beeCopterArchiveWatcherLog) << "Directory changed:" << path;

    QDir dir(path);
    if (!dir.exists()) {
        return;
    }

    // Get current file list
    const QStringList currentEntries = dir.entryList(QDir::Files);
    QSet<QString> currentFiles;
    for (const QString &entry : currentEntries) {
        currentFiles.insert(dir.absoluteFilePath(entry));
    }

    // Find new files
    QSet<QString> &knownFiles = _knownFiles[path];
    const QSet<QString> newFiles = currentFiles - knownFiles;

    // Update known files
    knownFiles = currentFiles;

    // Process new files
    for (const QString &filePath : newFiles) {
        _processNewFile(filePath);
    }
}

void beeCopterArchiveWatcher::_onExtractionProgress(qreal progress)
{
    _setProgress(progress);
}

void beeCopterArchiveWatcher::_onExtractionFinished(bool success)
{
    if (_cancelPending) {
        _cancelPending = false;
        _currentArchive.clear();
        _setExtracting(false);
        _setProgress(0.0);
        return;
    }

    qCDebug(beeCopterArchiveWatcherLog) << "Extraction finished:" << _currentArchive
                                   << "success:" << success;

    QString outputPath = _extractionJob->outputPath();
    QString errorString = success ? QString() : _extractionJob->errorString();

    // Remove source archive if configured and extraction succeeded
    if (success && _removeAfterExtraction) {
        if (QFile::remove(_currentArchive)) {
            qCDebug(beeCopterArchiveWatcherLog) << "Removed source archive:" << _currentArchive;
        } else {
            qCWarning(beeCopterArchiveWatcherLog) << "Failed to remove source archive:" << _currentArchive;
        }
    }

    emit extractionComplete(_currentArchive, outputPath, success, errorString);

    _currentArchive.clear();
    _setExtracting(false);
    _setProgress(0.0);

    // Process next pending extraction
    if (!_pendingExtractions.isEmpty()) {
        const QString next = _pendingExtractions.takeFirst();
        _startExtraction(next);
    }
}

// ============================================================================
// Private Methods
// ============================================================================

bool beeCopterArchiveWatcher::_isWatchedFormat(const QString &filePath) const
{
    const beeCopterCompression::Format format = beeCopterCompression::detectFormat(filePath);

    switch (_filterMode) {
    case FilterMode::Archives:
        return beeCopterCompression::isArchiveFormat(format);
    case FilterMode::Compressed:
        return beeCopterCompression::isCompressionFormat(format);
    case FilterMode::Both:
        return beeCopterCompression::isArchiveFormat(format) ||
               beeCopterCompression::isCompressionFormat(format);
    }

    return false;
}

void beeCopterArchiveWatcher::_processNewFile(const QString &filePath)
{
    if (!_isWatchedFormat(filePath)) {
        return;
    }

    const beeCopterCompression::Format format = beeCopterCompression::detectFormat(filePath);

    qCDebug(beeCopterArchiveWatcherLog) << "Detected archive:" << filePath
                                   << "format:" << beeCopterCompression::formatName(format);

    emit archiveDetected(filePath, format);

    if (_autoDecompress) {
        if (_extracting) {
            // Queue for later
            if (!_pendingExtractions.contains(filePath)) {
                _pendingExtractions.append(filePath);
                qCDebug(beeCopterArchiveWatcherLog) << "Queued for extraction:" << filePath;
            }
        } else {
            _startExtraction(filePath);
        }
    }
}

void beeCopterArchiveWatcher::_startExtraction(const QString &archivePath)
{
    if (!QFileInfo::exists(archivePath)) {
        qCWarning(beeCopterArchiveWatcherLog) << "Archive no longer exists:" << archivePath;
        return;
    }

    // Determine output path
    QString outputPath = _outputDirectory;
    if (outputPath.isEmpty()) {
        outputPath = QFileInfo(archivePath).absolutePath();
    }

    // For single-file compression, use decompressFile
    // For archives, use extractArchive
    const beeCopterCompression::Format format = beeCopterCompression::detectFormat(archivePath);
    const bool isArchive = beeCopterCompression::isArchiveFormat(format);

    qCDebug(beeCopterArchiveWatcherLog) << "Starting extraction:" << archivePath
                                   << "to" << outputPath
                                   << (isArchive ? "(archive)" : "(compressed file)");

    _currentArchive = archivePath;
    _cancelPending = false;
    _setExtracting(true);
    _setProgress(0.0);

    // Create extraction job if needed
    if (_extractionJob == nullptr) {
        _extractionJob = new beeCopterCompressionJob(this);
        connect(_extractionJob, &beeCopterCompressionJob::progressChanged,
                this, &beeCopterArchiveWatcher::_onExtractionProgress);
        connect(_extractionJob, &beeCopterCompressionJob::finished,
                this, &beeCopterArchiveWatcher::_onExtractionFinished);
    }

    if (isArchive) {
        _extractionJob->extractArchive(archivePath, outputPath);
    } else {
        // For compressed files, output is a file, not directory
        const QString strippedName = QFileInfo(beeCopterCompression::strippedPath(archivePath)).fileName();
        const QString decompressedPath = outputPath + "/" + strippedName;
        _extractionJob->decompressFile(archivePath, decompressedPath);
    }
}

void beeCopterArchiveWatcher::_setExtracting(bool extracting)
{
    if (_extracting != extracting) {
        _extracting = extracting;
        emit extractingChanged(_extracting);
    }
}

void beeCopterArchiveWatcher::_setProgress(qreal progress)
{
    if (!qFuzzyCompare(_progress, progress)) {
        _progress = progress;
        emit progressChanged(_progress);
    }
}
