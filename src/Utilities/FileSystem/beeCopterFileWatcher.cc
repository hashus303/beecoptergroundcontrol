#include "beeCopterFileWatcher.h"
#include "beeCopterLoggingCategory.h"

#include <QtCore/QDir>
#include <QtCore/QFileInfo>

beeCopter_LOGGING_CATEGORY(beeCopterFileWatcherLog, "Utilities.beeCopterFileWatcher")

// ============================================================================
// Construction / Destruction
// ============================================================================

beeCopterFileWatcher::beeCopterFileWatcher(QObject *parent)
    : QObject(parent)
    , _watcher(new QFileSystemWatcher(this))
    , _debounceTimer(new QTimer(this))
{
    connect(_watcher, &QFileSystemWatcher::fileChanged,
            this, &beeCopterFileWatcher::_onFileChanged);
    connect(_watcher, &QFileSystemWatcher::directoryChanged,
            this, &beeCopterFileWatcher::_onDirectoryChanged);

    _debounceTimer->setSingleShot(true);
    connect(_debounceTimer, &QTimer::timeout,
            this, &beeCopterFileWatcher::_processPendingChanges);
}

beeCopterFileWatcher::~beeCopterFileWatcher()
{
    clear();
}

// ============================================================================
// Configuration
// ============================================================================

void beeCopterFileWatcher::setDebounceDelay(int milliseconds)
{
    _debounceDelay = qMax(0, milliseconds);
}

// ============================================================================
// File Watching
// ============================================================================

bool beeCopterFileWatcher::watchFile(const QString &filePath, ChangeCallback callback)
{
    if (filePath.isEmpty()) {
        qCWarning(beeCopterFileWatcherLog) << "watchFile: empty path";
        return false;
    }

    const QString canonicalPath = QFileInfo(filePath).absoluteFilePath();

    if (!QFileInfo::exists(canonicalPath)) {
        qCWarning(beeCopterFileWatcherLog) << "watchFile: file does not exist:" << filePath;
        return false;
    }

    if (_watcher->addPath(canonicalPath)) {
        if (callback) {
            _fileCallbacks[canonicalPath] = callback;
        }
        qCDebug(beeCopterFileWatcherLog) << "Watching file:" << canonicalPath;
        return true;
    }

    // Already watching
    if (_watcher->files().contains(canonicalPath)) {
        if (callback) {
            _fileCallbacks[canonicalPath] = callback;
        }
        return true;
    }

    qCWarning(beeCopterFileWatcherLog) << "watchFile: failed to add:" << filePath;
    return false;
}

bool beeCopterFileWatcher::unwatchFile(const QString &filePath)
{
    const QString canonicalPath = QFileInfo(filePath).absoluteFilePath();

    _fileCallbacks.remove(canonicalPath);
    _persistentFiles.remove(canonicalPath);
    _pendingFileChanges.remove(canonicalPath);

    if (_watcher->removePath(canonicalPath)) {
        qCDebug(beeCopterFileWatcherLog) << "Stopped watching file:" << canonicalPath;
        return true;
    }

    return false;
}

bool beeCopterFileWatcher::isWatchingFile(const QString &filePath) const
{
    const QString canonicalPath = QFileInfo(filePath).absoluteFilePath();
    return _watcher->files().contains(canonicalPath);
}

QStringList beeCopterFileWatcher::watchedFiles() const
{
    return _watcher->files();
}

// ============================================================================
// Directory Watching
// ============================================================================

bool beeCopterFileWatcher::watchDirectory(const QString &directoryPath, ChangeCallback callback)
{
    if (directoryPath.isEmpty()) {
        qCWarning(beeCopterFileWatcherLog) << "watchDirectory: empty path";
        return false;
    }

    const QString canonicalPath = QFileInfo(directoryPath).absoluteFilePath();

    if (!QFileInfo(canonicalPath).isDir()) {
        qCWarning(beeCopterFileWatcherLog) << "watchDirectory: not a directory:" << directoryPath;
        return false;
    }

    if (_watcher->addPath(canonicalPath)) {
        if (callback) {
            _directoryCallbacks[canonicalPath] = callback;
        }
        qCDebug(beeCopterFileWatcherLog) << "Watching directory:" << canonicalPath;
        return true;
    }

    // Already watching
    if (_watcher->directories().contains(canonicalPath)) {
        if (callback) {
            _directoryCallbacks[canonicalPath] = callback;
        }
        return true;
    }

    qCWarning(beeCopterFileWatcherLog) << "watchDirectory: failed to add:" << directoryPath;
    return false;
}

bool beeCopterFileWatcher::unwatchDirectory(const QString &directoryPath)
{
    const QString canonicalPath = QFileInfo(directoryPath).absoluteFilePath();

    _directoryCallbacks.remove(canonicalPath);
    _pendingDirectoryChanges.remove(canonicalPath);

    if (_watcher->removePath(canonicalPath)) {
        qCDebug(beeCopterFileWatcherLog) << "Stopped watching directory:" << canonicalPath;
        return true;
    }

    return false;
}

bool beeCopterFileWatcher::isWatchingDirectory(const QString &directoryPath) const
{
    const QString canonicalPath = QFileInfo(directoryPath).absoluteFilePath();
    return _watcher->directories().contains(canonicalPath);
}

QStringList beeCopterFileWatcher::watchedDirectories() const
{
    return _watcher->directories();
}

// ============================================================================
// Bulk Operations
// ============================================================================

int beeCopterFileWatcher::watchFiles(const QStringList &filePaths, ChangeCallback callback)
{
    int count = 0;
    for (const QString &path : filePaths) {
        if (watchFile(path, callback)) {
            count++;
        }
    }
    return count;
}

int beeCopterFileWatcher::watchDirectories(const QStringList &directoryPaths, ChangeCallback callback)
{
    int count = 0;
    for (const QString &path : directoryPaths) {
        if (watchDirectory(path, callback)) {
            count++;
        }
    }
    return count;
}

void beeCopterFileWatcher::clear()
{
    const QStringList files = _watcher->files();
    if (!files.isEmpty()) {
        _watcher->removePaths(files);
    }

    const QStringList dirs = _watcher->directories();
    if (!dirs.isEmpty()) {
        _watcher->removePaths(dirs);
    }

    _fileCallbacks.clear();
    _directoryCallbacks.clear();
    _persistentFiles.clear();
    _pendingFileChanges.clear();
    _pendingDirectoryChanges.clear();
    _debounceTimer->stop();

    qCDebug(beeCopterFileWatcherLog) << "Cleared all watches";
}

// ============================================================================
// Persistent File Watching
// ============================================================================

bool beeCopterFileWatcher::watchFilePersistent(const QString &filePath, ChangeCallback callback)
{
    const QString canonicalPath = QFileInfo(filePath).absoluteFilePath();

    // Watch the parent directory to detect file recreation
    const QString parentDir = QFileInfo(canonicalPath).absolutePath();
    if (!_watcher->directories().contains(parentDir)) {
        _watcher->addPath(parentDir);
    }

    _persistentFiles.insert(canonicalPath);

    if (QFileInfo::exists(canonicalPath)) {
        return watchFile(canonicalPath, callback);
    }

    // File doesn't exist yet - store callback for when it's created
    if (callback) {
        _fileCallbacks[canonicalPath] = callback;
    }

    qCDebug(beeCopterFileWatcherLog) << "Watching file (persistent):" << canonicalPath;
    return true;
}

// ============================================================================
// Internal Slots
// ============================================================================

void beeCopterFileWatcher::_onFileChanged(const QString &path)
{
    qCDebug(beeCopterFileWatcherLog) << "File changed:" << path;

    // Handle persistent files that were deleted
    if (_persistentFiles.contains(path) && !QFileInfo::exists(path)) {
        // File was deleted - will be re-added when directory changes detect recreation
        qCDebug(beeCopterFileWatcherLog) << "Persistent file deleted, waiting for recreation:" << path;
    }

    _scheduleCallback(path, false);
}

void beeCopterFileWatcher::_onDirectoryChanged(const QString &path)
{
    qCDebug(beeCopterFileWatcherLog) << "Directory changed:" << path;

    // Check for recreated persistent files
    for (const QString &persistentPath : std::as_const(_persistentFiles)) {
        if (persistentPath.startsWith(path) && QFileInfo::exists(persistentPath)) {
            if (!_watcher->files().contains(persistentPath)) {
                _watcher->addPath(persistentPath);
                qCDebug(beeCopterFileWatcherLog) << "Re-added persistent file:" << persistentPath;

                // Trigger callback for recreated file
                _scheduleCallback(persistentPath, false);
            }
        }
    }

    _scheduleCallback(path, true);
}

void beeCopterFileWatcher::_scheduleCallback(const QString &path, bool isDirectory)
{
    if (isDirectory) {
        _pendingDirectoryChanges.insert(path);
    } else {
        _pendingFileChanges.insert(path);
    }

    if (_debounceDelay > 0) {
        if (!_debounceTimer->isActive()) {
            _debounceTimer->start(_debounceDelay);
        }
    } else if (!_processingPendingChanges) {
        // No debounce - process immediately
        _processPendingChanges();
    }
}

void beeCopterFileWatcher::_processPendingChanges()
{
    if (_processingPendingChanges) {
        return;
    }

    _processingPendingChanges = true;

    do {
        const QSet<QString> fileChanges = _pendingFileChanges;
        const QSet<QString> directoryChanges = _pendingDirectoryChanges;
        _pendingFileChanges.clear();
        _pendingDirectoryChanges.clear();

        for (const QString &path : fileChanges) {
            emit fileChanged(path);

            auto it = _fileCallbacks.find(path);
            if (it != _fileCallbacks.end() && it.value()) {
                it.value()(path);
            }
        }

        for (const QString &path : directoryChanges) {
            emit directoryChanged(path);

            auto it = _directoryCallbacks.find(path);
            if (it != _directoryCallbacks.end() && it.value()) {
                it.value()(path);
            }
        }
    } while ((_debounceDelay == 0) && (!_pendingFileChanges.isEmpty() || !_pendingDirectoryChanges.isEmpty()));

    _processingPendingChanges = false;
}
