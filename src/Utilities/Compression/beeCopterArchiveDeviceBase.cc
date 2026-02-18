#include "beeCopterArchiveDeviceBase.h"
#include "beeCopterFileHelper.h"
#include "beeCopterlibarchive.h"
#include "beeCopterLoggingCategory.h"

#include <archive.h>
#include <archive_entry.h>

#include <cstring>

beeCopter_LOGGING_CATEGORY(beeCopterArchiveDeviceBaseLog, "Utilities.beeCopterArchiveDeviceBase")

// ============================================================================
// Constructors / Destructor
// ============================================================================

beeCopterArchiveDeviceBase::beeCopterArchiveDeviceBase(const QString &filePath, QObject *parent)
    : QIODevice(parent)
    , _filePath(filePath)
    , _ownsSource(true)
{
}

beeCopterArchiveDeviceBase::beeCopterArchiveDeviceBase(QIODevice *source, QObject *parent)
    : QIODevice(parent)
    , _sourceDevice(source)
    , _ownsSource(false)
{
}

beeCopterArchiveDeviceBase::~beeCopterArchiveDeviceBase()
{
    close();
}

// ============================================================================
// QIODevice Interface
// ============================================================================

void beeCopterArchiveDeviceBase::close()
{
    if (_archive) {
        archive_read_free(_archive);
        _archive = nullptr;
    }

    resetState();

    if (_ownsSource) {
        _ownedSource.reset();
        _sourceDevice = nullptr;
    }

    QIODevice::close();
}

qint64 beeCopterArchiveDeviceBase::bytesAvailable() const
{
    return _buffer.size() + QIODevice::bytesAvailable();
}

QString beeCopterArchiveDeviceBase::errorString() const
{
    if (!_errorString.isEmpty()) {
        return _errorString;
    }
    return QIODevice::errorString();
}

// ============================================================================
// Protected QIODevice Methods
// ============================================================================

qint64 beeCopterArchiveDeviceBase::readData(char *data, qint64 maxSize)
{
    if (!isReadyToRead()) {
        return -1;
    }

    if (_eof && _buffer.isEmpty()) {
        return 0;  // EOF
    }

    // Fill buffer if needed
    while (_buffer.size() < maxSize && !_eof) {
        if (!fillBuffer()) {
            if (_buffer.isEmpty()) {
                return _eof ? 0 : -1;
            }
            break;
        }
    }

    // Return data from buffer
    const qint64 bytesToCopy = qMin(static_cast<qint64>(_buffer.size()), maxSize);
    if (bytesToCopy > 0) {
        std::memcpy(data, _buffer.constData(), static_cast<size_t>(bytesToCopy));
        _buffer.remove(0, static_cast<int>(bytesToCopy));
    }

    return bytesToCopy;
}

qint64 beeCopterArchiveDeviceBase::writeData(const char *, qint64)
{
    return -1;  // Read-only device
}

// ============================================================================
// Protected Implementation Methods
// ============================================================================

bool beeCopterArchiveDeviceBase::initSourceFromPath()
{
    if (_filePath.isEmpty()) {
        _errorString = QStringLiteral("File path is empty");
        return false;
    }

    const bool isResource = beeCopterFileHelper::isQtResource(_filePath);

    if (isResource) {
        // Load Qt resource into memory
        QFile resourceFile(_filePath);
        if (!resourceFile.open(QIODevice::ReadOnly)) {
            _errorString = QStringLiteral("Failed to open resource: ") + _filePath;
            return false;
        }
        _resourceData = resourceFile.readAll();
        resourceFile.close();

        // Create QBuffer as source
        auto buffer = std::make_unique<QBuffer>();
        buffer->setData(_resourceData);
        if (!buffer->open(QIODevice::ReadOnly)) {
            _errorString = QStringLiteral("Failed to open buffer for resource");
            return false;
        }
        _ownedSource = std::move(buffer);
        _sourceDevice = _ownedSource.get();
    } else {
        auto file = std::make_unique<QFile>(_filePath);
        if (!file->open(QIODevice::ReadOnly)) {
            _errorString = QStringLiteral("Failed to open file: ") + _filePath;
            return false;
        }
        _ownedSource = std::move(file);
        _sourceDevice = _ownedSource.get();
    }

    return true;
}

void beeCopterArchiveDeviceBase::configureArchiveFormats(bool allFormats)
{
    if (!_archive) {
        return;
    }

    archive_read_support_filter_all(_archive);

    if (allFormats) {
        archive_read_support_format_all(_archive);
    } else {
        archive_read_support_format_raw(_archive);
    }
}

bool beeCopterArchiveDeviceBase::openArchive()
{
    if (!_sourceDevice || !_sourceDevice->isOpen() || !_sourceDevice->isReadable()) {
        _errorString = QStringLiteral("Source device is not ready");
        return false;
    }

    // Enable seek callback for random-access devices (improves ZIP performance)
    if (!_sourceDevice->isSequential()) {
        archive_read_set_seek_callback(_archive, beeCopterlibarchive::deviceSeekCallback);
    }

    const int result = archive_read_open2(_archive, _sourceDevice,
                                          nullptr,  // open callback
                                          beeCopterlibarchive::deviceReadCallback,
                                          beeCopterlibarchive::deviceSkipCallback,
                                          beeCopterlibarchive::deviceCloseCallback);

    if (result != ARCHIVE_OK) {
        _errorString = QString::fromUtf8(archive_error_string(_archive));
        archive_read_free(_archive);
        _archive = nullptr;
        return false;
    }

    return true;
}

bool beeCopterArchiveDeviceBase::fillBuffer()
{
    if (_eof || !_archive) {
        return false;
    }

    char readBuffer[beeCopterFileHelper::kBufferSizeMax];
    const la_ssize_t bytesRead = archive_read_data(_archive, readBuffer, sizeof(readBuffer));

    if (bytesRead < 0) {
        _errorString = QString::fromUtf8(archive_error_string(_archive));
        qCWarning(beeCopterArchiveDeviceBaseLog) << "Read error:" << _errorString;
        return false;
    }

    if (bytesRead == 0) {
        _eof = true;
        return false;
    }

    _buffer.append(readBuffer, static_cast<int>(bytesRead));
    return true;
}

void beeCopterArchiveDeviceBase::captureFormatInfo()
{
    if (!_archive) {
        return;
    }

    const char *fmt = archive_format_name(_archive);
    _formatName = fmt ? QString::fromUtf8(fmt) : QString();

    const char *flt = archive_filter_name(_archive, 0);
    _filterName = flt ? QString::fromUtf8(flt) : QStringLiteral("none");
}

void beeCopterArchiveDeviceBase::resetState()
{
    _buffer.clear();
    _eof = false;
    _formatName.clear();
    _filterName.clear();
}
