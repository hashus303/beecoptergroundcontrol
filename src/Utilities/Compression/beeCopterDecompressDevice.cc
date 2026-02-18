#include "beeCopterDecompressDevice.h"
#include "beeCopterLoggingCategory.h"

#include <archive.h>
#include <archive_entry.h>

beeCopter_LOGGING_CATEGORY(beeCopterDecompressDeviceLog, "Utilities.beeCopterDecompressDevice")

// ============================================================================
// Constructors
// ============================================================================

beeCopterDecompressDevice::beeCopterDecompressDevice(QIODevice *source, QObject *parent)
    : beeCopterArchiveDeviceBase(source, parent)
{
}

beeCopterDecompressDevice::beeCopterDecompressDevice(const QString &filePath, QObject *parent)
    : beeCopterArchiveDeviceBase(filePath, parent)
{
}

// ============================================================================
// QIODevice Interface
// ============================================================================

bool beeCopterDecompressDevice::open(OpenMode mode)
{
    if (mode != ReadOnly) {
        _errorString = QStringLiteral("beeCopterDecompressDevice only supports ReadOnly mode");
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

// ============================================================================
// Protected Implementation
// ============================================================================

bool beeCopterDecompressDevice::initArchive()
{
    _archive = archive_read_new();
    if (!_archive) {
        _errorString = QStringLiteral("Failed to create archive reader");
        return false;
    }

    // Raw format for single-file decompression
    configureArchiveFormats(false);

    return openArchive();
}

bool beeCopterDecompressDevice::prepareForReading()
{
    // Read the first (and only) entry header for raw format
    struct archive_entry *entry = nullptr;
    if (archive_read_next_header(_archive, &entry) != ARCHIVE_OK) {
        _errorString = QString::fromUtf8(archive_error_string(_archive));
        archive_read_free(_archive);
        _archive = nullptr;
        return false;
    }

    _headerRead = true;
    captureFormatInfo();

    qCDebug(beeCopterDecompressDeviceLog) << "Opened compressed stream, format:" << _formatName
                                     << "filter:" << _filterName;

    return true;
}

void beeCopterDecompressDevice::resetState()
{
    beeCopterArchiveDeviceBase::resetState();
    _headerRead = false;
}
