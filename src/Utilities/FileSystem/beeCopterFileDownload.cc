#include "beeCopterFileDownload.h"
#include "beeCopterCompression.h"
#include "beeCopterCompressionJob.h"
#include "beeCopterFileHelper.h"
#include "beeCopterLoggingCategory.h"

#include <QtCore/QFile>
#include <QtCore/QFileInfo>
#include <QtCore/QStandardPaths>
#include <QtNetwork/QNetworkAccessManager>

beeCopter_LOGGING_CATEGORY(beeCopterFileDownloadLog, "Utilities.beeCopterFileDownload")

beeCopterFileDownload::beeCopterFileDownload(QObject *parent)
    : QObject(parent)
    , _networkManager(beeCopterNetworkHelper::createNetworkManager(this))
{
    qCDebug(beeCopterFileDownloadLog) << "Created" << this;
}

beeCopterFileDownload::~beeCopterFileDownload()
{
    qCDebug(beeCopterFileDownloadLog) << "Destroying" << this;
    cancel();
}

// ============================================================================
// Property Setters
// ============================================================================

void beeCopterFileDownload::setAutoDecompress(bool enabled)
{
    if (_autoDecompress != enabled) {
        _autoDecompress = enabled;
        emit autoDecompressChanged(enabled);
    }
}

void beeCopterFileDownload::setOutputPath(const QString &path)
{
    if (_outputPath != path) {
        _outputPath = path;
        emit outputPathChanged(path);
    }
}

void beeCopterFileDownload::setExpectedHash(const QString &hash)
{
    if (_expectedHash != hash) {
        _expectedHash = hash;
        emit expectedHashChanged(hash);
    }
}

void beeCopterFileDownload::setCache(QAbstractNetworkCache *cache)
{
    _networkManager->setCache(cache);
}

void beeCopterFileDownload::setTimeout(int timeoutMs)
{
    _timeoutMs = timeoutMs;
}

// ============================================================================
// Public Slots
// ============================================================================

bool beeCopterFileDownload::start(const QString &remoteUrl)
{
    beeCopterNetworkHelper::RequestConfig config;
    config.timeoutMs = _timeoutMs;
    config.allowRedirects = true;
    return start(remoteUrl, config);
}

bool beeCopterFileDownload::start(const QString &remoteUrl, const beeCopterNetworkHelper::RequestConfig &config)
{
    if (isRunning()) {
        qCWarning(beeCopterFileDownloadLog) << "Download already in progress";
        return false;
    }

    if (remoteUrl.isEmpty()) {
        qCWarning(beeCopterFileDownloadLog) << "Empty URL provided";
        _setErrorString(tr("Empty URL"));
        return false;
    }

    // Parse URL
    QUrl url;
    if (beeCopterFileHelper::isLocalPath(remoteUrl)) {
        url = QUrl::fromLocalFile(beeCopterFileHelper::toLocalPath(remoteUrl));
    } else if (remoteUrl.startsWith(QLatin1String("http:")) || remoteUrl.startsWith(QLatin1String("https:"))) {
        url.setUrl(remoteUrl);
    } else {
        // Assume it's a local file path
        url = QUrl::fromLocalFile(remoteUrl);
    }

    if (!url.isValid()) {
        qCWarning(beeCopterFileDownloadLog) << "Invalid URL:" << remoteUrl;
        _setErrorString(tr("Invalid URL: %1").arg(remoteUrl));
        return false;
    }

    // Reset state
    _cleanup();
    _url = url;
    emit urlChanged(_url);
    _bytesReceived = 0;
    emit bytesReceivedChanged(0);
    _totalBytes = -1;
    emit totalBytesChanged(-1);
    _setProgress(0.0);
    _setErrorString(QString());
    _finishEmitted = false;
    _lastResultFromCache = false;

    // Determine output path
    _localPath = _generateOutputPath(remoteUrl);
    if (_localPath.isEmpty()) {
        _setErrorString(tr("Unable to determine output path"));
        return false;
    }
    emit localPathChanged(_localPath);

    // Ensure parent directory exists
    if (!beeCopterFileHelper::ensureParentExists(_localPath)) {
        _setErrorString(tr("Cannot create output directory"));
        return false;
    }

    // Open output file for streaming write
    _outputFile = new QFile(_localPath, this);
    if (!_outputFile->open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        _setErrorString(tr("Cannot open output file: %1").arg(_outputFile->errorString()));
        delete _outputFile;
        _outputFile = nullptr;
        return false;
    }

    // Create request with configuration
    QNetworkRequest request = beeCopterNetworkHelper::createRequest(url, config);

    qCDebug(beeCopterFileDownloadLog) << "Starting download:" << url.toString() << "to" << _localPath;

    // Start download
    _currentReply = _networkManager->get(request);
    if (_currentReply == nullptr) {
        qCWarning(beeCopterFileDownloadLog) << "QNetworkAccessManager::get failed";
        _setErrorString(tr("Failed to start download"));
        _outputFile->close();
        delete _outputFile;
        _outputFile = nullptr;
        return false;
    }

    beeCopterNetworkHelper::ignoreSslErrorsIfNeeded(_currentReply);

    // Connect signals for streaming download
    connect(_currentReply, &QNetworkReply::downloadProgress,
            this, &beeCopterFileDownload::_onDownloadProgress);
    connect(_currentReply, &QNetworkReply::readyRead,
            this, &beeCopterFileDownload::_onReadyRead);
    connect(_currentReply, &QNetworkReply::finished,
            this, &beeCopterFileDownload::_onDownloadFinished);
    connect(_currentReply, &QNetworkReply::errorOccurred,
            this, &beeCopterFileDownload::_onDownloadError);

    _setState(State::Downloading);
    return true;
}

void beeCopterFileDownload::cancel()
{
    const bool shouldEmitCancel = (_state != State::Idle && _state != State::Completed
                                   && _state != State::Failed && _state != State::Cancelled);

    if (shouldEmitCancel) {
        _setState(State::Cancelled);
        _setErrorString(tr("Download cancelled"));
        _emitFinished(false, QString(), _errorString);
    }

    if (_currentReply != nullptr) {
        qCDebug(beeCopterFileDownloadLog) << "Cancelling download";
        _currentReply->abort();
    }

    if (_decompressionJob != nullptr && _decompressionJob->isRunning()) {
        _decompressionJob->cancel();
    }

    _cleanup();
}

// ============================================================================
// Private Slots
// ============================================================================

void beeCopterFileDownload::_onDownloadProgress(qint64 bytesReceived, qint64 totalBytes)
{
    _bytesReceived = bytesReceived;
    emit bytesReceivedChanged(bytesReceived);

    if (totalBytes != _totalBytes) {
        _totalBytes = totalBytes;
        emit totalBytesChanged(totalBytes);
    }

    if (totalBytes > 0) {
        _setProgress(static_cast<qreal>(bytesReceived) / static_cast<qreal>(totalBytes));
    }

    emit downloadProgress(bytesReceived, totalBytes);
}

void beeCopterFileDownload::_onReadyRead()
{
    if (_currentReply == nullptr || _outputFile == nullptr) {
        return;
    }

    // Stream data directly to file (memory-efficient)
    const QByteArray data = _currentReply->readAll();
    if (!_writeReplyData(data)) {
        _failForWriteError(QStringLiteral("readyRead"));
    }
}

void beeCopterFileDownload::_onDownloadFinished()
{
    QNetworkReply *reply = _currentReply;
    _currentReply = nullptr;

    if (reply == nullptr) {
        return;
    }
    reply->deleteLater();

    if (_state == State::Cancelled) {
        _cleanup();
        return;
    }

    _lastResultFromCache = reply->attribute(QNetworkRequest::SourceIsFromCacheAttribute).toBool();

    // Close output file
    if (_outputFile != nullptr) {
        // Write any remaining data
        const QByteArray remaining = reply->readAll();
        if (!_writeReplyData(remaining)) {
            _outputFile->close();
            delete _outputFile;
            _outputFile = nullptr;
            _failForWriteError(QStringLiteral("finished"));
            return;
        }
        _outputFile->close();
        delete _outputFile;
        _outputFile = nullptr;
    }

    // Check for errors
    if (reply->error() != QNetworkReply::NoError) {
        // Error already handled in _onDownloadError
        if (_state == State::Downloading || _state == State::Verifying) {
            _setState(State::Failed);
            _emitFinished(false, QString(), beeCopterNetworkHelper::errorMessage(reply));
        }
        return;
    }

    // Check HTTP status for non-local files
    if (!reply->url().isLocalFile()) {
        const int statusCode = beeCopterNetworkHelper::httpStatusCode(reply);
        if (!beeCopterNetworkHelper::isHttpSuccess(statusCode)) {
            const QString error = tr("HTTP error %1: %2")
                .arg(statusCode)
                .arg(beeCopterNetworkHelper::httpStatusText(statusCode));
            _setErrorString(error);
            _setState(State::Failed);
            _emitFinished(false, QString(), error);
            return;
        }
    }

    qCDebug(beeCopterFileDownloadLog) << "Download finished:" << _localPath
                                 << "size:" << QFileInfo(_localPath).size();

    // Verify hash if expected
    if (!_expectedHash.isEmpty()) {
        _setState(State::Verifying);
        if (!_verifyHash()) {
            _setState(State::Failed);
            _emitFinished(false, QString(), _errorString);
            return;
        }
    }

    // Auto-decompress if enabled and file is compressed
    if (_autoDecompress && beeCopterCompression::isCompressedFile(_localPath)) {
        _startDecompression();
        return;
    }

    // Success!
    _setState(State::Completed);
    _emitFinished(true, _localPath, QString());
}

void beeCopterFileDownload::_onDownloadError(QNetworkReply::NetworkError code)
{
    if (_state == State::Cancelled) {
        return;
    }

    QString errorMsg;

    switch (code) {
    case QNetworkReply::OperationCanceledError:
        errorMsg = tr("Download cancelled");
        break;
    case QNetworkReply::ContentNotFoundError:
        errorMsg = tr("File not found (404)");
        break;
    case QNetworkReply::TimeoutError:
        errorMsg = tr("Connection timed out");
        break;
    case QNetworkReply::HostNotFoundError:
        errorMsg = tr("Host not found");
        break;
    case QNetworkReply::ConnectionRefusedError:
        errorMsg = tr("Connection refused");
        break;
    case QNetworkReply::SslHandshakeFailedError:
        errorMsg = tr("SSL handshake failed");
        break;
    default:
        if (_currentReply != nullptr) {
            errorMsg = beeCopterNetworkHelper::errorMessage(_currentReply);
        } else {
            errorMsg = tr("Network error: %1").arg(code);
        }
        break;
    }

    qCWarning(beeCopterFileDownloadLog) << "Download error:" << errorMsg;
    _setErrorString(errorMsg);
}

void beeCopterFileDownload::_onDecompressionFinished(bool success)
{
    if (_state == State::Cancelled) {
        _compressedFilePath.clear();
        return;
    }

    if (success) {
        const QString decompressedPath = _decompressionJob->outputPath();
        qCDebug(beeCopterFileDownloadLog) << "Decompression completed:" << decompressedPath;

        // Remove compressed file if different from output
        if (_compressedFilePath != decompressedPath && QFile::exists(_compressedFilePath)) {
            QFile::remove(_compressedFilePath);
        }

        _localPath = decompressedPath;
        emit localPathChanged(_localPath);

        _setState(State::Completed);
        _emitFinished(true, _localPath, QString());
    } else {
        const QString error = tr("Decompression failed: %1").arg(_decompressionJob->errorString());
        qCWarning(beeCopterFileDownloadLog) << error;
        _setErrorString(error);
        _setState(State::Failed);

        // Return compressed file path on decompression failure
        _emitFinished(false, _compressedFilePath, error);
    }

    _compressedFilePath.clear();
}

// ============================================================================
// Private Methods
// ============================================================================

void beeCopterFileDownload::_setState(State newState)
{
    if (_state != newState) {
        const bool wasRunning = isRunning();
        _state = newState;
        emit stateChanged(newState);

        if (wasRunning != isRunning()) {
            emit runningChanged(isRunning());
        }
    }
}

void beeCopterFileDownload::_setProgress(qreal progress)
{
    if (!qFuzzyCompare(_progress, progress)) {
        _progress = progress;
        emit progressChanged(progress);
    }
}

void beeCopterFileDownload::_setErrorString(const QString &error)
{
    if (_errorString != error) {
        _errorString = error;
        emit errorStringChanged(error);
    }
}

void beeCopterFileDownload::_cleanup()
{
    if (_currentReply != nullptr) {
        _currentReply->disconnect(this);
        _currentReply->deleteLater();
        _currentReply = nullptr;
    }

    if (_outputFile != nullptr) {
        if (_outputFile->isOpen()) {
            _outputFile->close();
        }
        delete _outputFile;
        _outputFile = nullptr;
    }
}

void beeCopterFileDownload::_emitFinished(bool success, const QString &localPath, const QString &errorMessage)
{
    if (_finishEmitted) {
        return;
    }
    _finishEmitted = true;
    emit finished(success, localPath, errorMessage);
}

bool beeCopterFileDownload::_writeReplyData(const QByteArray &data)
{
    if (data.isEmpty()) {
        return true;
    }

    if (_outputFile == nullptr) {
        return false;
    }

    return _outputFile->write(data) == data.size();
}

bool beeCopterFileDownload::_failForWriteError(const QString &context)
{
    const QString error = tr("Failed to write downloaded file (%1): %2")
                              .arg(context, _outputFile != nullptr ? _outputFile->errorString() : QString());
    qCWarning(beeCopterFileDownloadLog) << error;
    _setErrorString(error);
    _setState(State::Failed);

    if (_currentReply != nullptr) {
        _currentReply->disconnect(this);
        _currentReply->abort();
    }

    _cleanup();
    _emitFinished(false, QString(), error);
    return false;
}

QString beeCopterFileDownload::_generateOutputPath(const QString &remoteUrl) const
{
    // Use custom output path if set
    if (!_outputPath.isEmpty()) {
        return _outputPath;
    }

    // Extract filename from URL
    QString fileName = beeCopterNetworkHelper::urlFileName(QUrl(remoteUrl));
    if (fileName.isEmpty()) {
        fileName = QStringLiteral("DownloadedFile");
    }

    // Strip query parameters
    const int queryIndex = fileName.indexOf(QLatin1Char('?'));
    if (queryIndex != -1) {
        fileName = fileName.left(queryIndex);
    }

    // Find writable directory
    QString downloadDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    if (downloadDir.isEmpty()) {
        downloadDir = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    }

    if (downloadDir.isEmpty()) {
        qCWarning(beeCopterFileDownloadLog) << "No writable download location found";
        return QString();
    }

    return beeCopterFileHelper::joinPath(downloadDir, fileName);
}

bool beeCopterFileDownload::_verifyHash()
{
    qCDebug(beeCopterFileDownloadLog) << "Verifying hash for:" << _localPath;

    const QString actualHash = beeCopterFileHelper::computeFileHash(_localPath);
    if (actualHash.isEmpty()) {
        _setErrorString(tr("Failed to compute file hash"));
        return false;
    }

    if (actualHash.compare(_expectedHash, Qt::CaseInsensitive) != 0) {
        _setErrorString(tr("Hash verification failed. Expected: %1, Got: %2")
                        .arg(_expectedHash, actualHash));
        return false;
    }

    qCDebug(beeCopterFileDownloadLog) << "Hash verified successfully";
    return true;
}

void beeCopterFileDownload::_startDecompression()
{
    _compressedFilePath = _localPath;
    const QString decompressedPath = beeCopterCompression::strippedPath(_localPath);

    qCDebug(beeCopterFileDownloadLog) << "Starting decompression:" << _localPath << "->" << decompressedPath;

    _setState(State::Decompressing);

    if (_decompressionJob == nullptr) {
        _decompressionJob = new beeCopterCompressionJob(this);
        connect(_decompressionJob, &beeCopterCompressionJob::progressChanged,
                this, &beeCopterFileDownload::decompressionProgress);
        connect(_decompressionJob, &beeCopterCompressionJob::finished,
                this, &beeCopterFileDownload::_onDecompressionFinished);
    }

    _decompressionJob->decompressFile(_localPath, decompressedPath);
}
