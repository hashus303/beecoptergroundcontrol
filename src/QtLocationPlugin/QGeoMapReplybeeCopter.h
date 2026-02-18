#pragma once

#include <QtCore/QLoggingCategory>
#include <QtLocation/private/qgeotiledmapreply_p.h>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkRequest>

#include "beeCopterMapTasks.h"

Q_DECLARE_LOGGING_CATEGORY(QGeoTiledMapReplybeeCopterLog)

class QNetworkAccessManager;
class QSslError;

class QGeoTiledMapReplybeeCopter : public QGeoTiledMapReply
{
    Q_OBJECT

public:
    explicit QGeoTiledMapReplybeeCopter(QNetworkAccessManager *networkManager, const QNetworkRequest &request, const QGeoTileSpec &spec, QObject *parent = nullptr);
    ~QGeoTiledMapReplybeeCopter();

    bool init();
    void abort() final;

private slots:
    void _networkReplyFinished();
    void _networkReplyError(QNetworkReply::NetworkError error);
    void _networkReplySslErrors(const QList<QSslError> &errors);
    void _cacheReply(beeCopterCacheTile *tile);
    void _cacheError(beeCopterMapTask::TaskType type, QStringView errorString);

private:
    static void _initDataFromResources();

    QNetworkAccessManager *_networkManager = nullptr;
    QNetworkRequest _request;
    bool m_initialized = false;

    static QByteArray _bingNoTileImage;
    static QByteArray _badTile;
};
