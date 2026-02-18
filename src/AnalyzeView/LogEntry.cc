#include "LogEntry.h"
#include "beeCopterApplication.h"
#include "beeCopterLoggingCategory.h"

#include <QtCore/QtMath>

beeCopter_LOGGING_CATEGORY(LogEntryLog, "AnalyzeView.beeCopterLogEntry")

LogDownloadData::LogDownloadData(beeCopterLogEntry * const logEntry)
    : ID(logEntry->id())
    , entry(logEntry)
{
    // qCDebug(LogEntryLog) << Q_FUNC_INFO << this;
}

LogDownloadData::~LogDownloadData()
{
    // qCDebug(LogEntryLog) << Q_FUNC_INFO << this;
}

void LogDownloadData::advanceChunk()
{
    ++current_chunk;
    chunk_table = QBitArray(chunkBins(), false);
}

uint32_t LogDownloadData::chunkBins() const
{
    const qreal num = static_cast<qreal>((entry->size() - (current_chunk * kChunkSize))) / static_cast<qreal>(MAVLINK_MSG_LOG_DATA_FIELD_DATA_LEN);
    return qMin(static_cast<uint32_t>(qCeil(num)), kTableBins);
}

uint32_t LogDownloadData::numChunks() const
{
    const qreal num = static_cast<qreal>(entry->size()) / static_cast<qreal>(kChunkSize);
    return qCeil(num);
}

bool LogDownloadData::chunkEquals(const bool val) const
{
    return (chunk_table == QBitArray(chunk_table.size(), val));
}

/*===========================================================================*/

beeCopterLogEntry::beeCopterLogEntry(uint logId, const QDateTime &dateTime, uint logSize, bool received, QObject *parent)
    : QObject(parent)
    , _logID(logId)
    , _logSize(logSize)
    , _logTimeUTC(dateTime)
    , _received(received)
{
    // qCDebug(LogEntryLog) << Q_FUNC_INFO << this;
}

beeCopterLogEntry::~beeCopterLogEntry()
{
    // qCDebug(LogEntryLog) << Q_FUNC_INFO << this;
}

QString beeCopterLogEntry::sizeStr() const
{
    return beeCopterApp()->bigSizeToString(_logSize);
}
