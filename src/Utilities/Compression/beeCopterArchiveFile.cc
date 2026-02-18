#include "beeCopterArchiveFile.h"
#include "beeCopterLoggingCategory.h"

#include <archive.h>
#include <archive_entry.h>

beeCopter_LOGGING_CATEGORY(beeCopterArchiveFileLog, "Utilities.beeCopterArchiveFile")

// ============================================================================
// Constructors
// ============================================================================

beeCopterArchiveFile::beeCopterArchiveFile(const QString &archivePath, const QString &entryName, QObject *parent)
    : beeCopterArchiveDeviceBase(archivePath, parent)
    , _entryName(entryName)
{
}

beeCopterArchiveFile::beeCopterArchiveFile(QIODevice *source, const QString &entryName, QObject *parent)
    : beeCopterArchiveDeviceBase(source, parent)
    , _entryName(entryName)
{
}

// ============================================================================
// QIODevice Interface
// ============================================================================

bool beeCopterArchiveFile::open(OpenMode mode)
{
    if (mode != ReadOnly) {
        _errorString = QStringLiteral("beeCopterArchiveFile only supports ReadOnly mode");
        return false;
    }

    if (_entryName.isEmpty()) {
        _errorString = QStringLiteral("Entry name cannot be empty");
        return false;
    }

    // Handle file path constructor
    if (!_filePath.isEmpty()) {
        if (!initSourceFromPath()) {
            return false;
        }
    }

    if (!initArchive()) {
        return false;
    }

    if (!prepareForReading()) {
        return false;
    }

    return QIODevice::open(mode);
}

qint64 beeCopterArchiveFile::size() const
{
    return _entrySize >= 0 ? _entrySize : QIODevice::size();
}

// ============================================================================
// Protected Implementation
// ============================================================================

bool beeCopterArchiveFile::initArchive()
{
    _archive = archive_read_new();
    if (!_archive) {
        _errorString = QStringLiteral("Failed to create archive reader");
        return false;
    }

    // All formats for archives
    configureArchiveFormats(true);

    return openArchive();
}

bool beeCopterArchiveFile::prepareForReading()
{
    return seekToEntry();
}

void beeCopterArchiveFile::resetState()
{
    beeCopterArchiveDeviceBase::resetState();
    _entryFound = false;
    _entrySize = -1;
    _entryModified = QDateTime();
}

// ============================================================================
// Private Methods
// ============================================================================

bool beeCopterArchiveFile::seekToEntry()
{
    struct archive_entry *entry = nullptr;
    _entryFound = false;

    while (archive_read_next_header(_archive, &entry) == ARCHIVE_OK) {
        // Capture format info on first header
        if (_formatName.isEmpty()) {
            captureFormatInfo();
        }

        const QString currentEntry = QString::fromUtf8(archive_entry_pathname(entry));

        if (currentEntry == _entryName) {
            _entryFound = true;
            _entrySize = archive_entry_size(entry);

            // Get modification time if available
            if (archive_entry_mtime_is_set(entry)) {
                _entryModified = QDateTime::fromSecsSinceEpoch(archive_entry_mtime(entry));
            }

            qCDebug(beeCopterArchiveFileLog) << "Found entry:" << _entryName
                                        << "size:" << _entrySize
                                        << "modified:" << _entryModified;
            return true;
        }

        // Skip this entry's data
        archive_read_data_skip(_archive);
    }

    _errorString = QStringLiteral("Entry not found in archive: ") + _entryName;
    return false;
}
