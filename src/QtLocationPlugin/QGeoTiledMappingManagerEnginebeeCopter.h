#pragma once

#include <QtCore/QLoggingCategory>
#include <QtLocation/QGeoServiceProvider>
#include <QtLocation/private/qgeotiledmappingmanagerengine_p.h>

Q_DECLARE_LOGGING_CATEGORY(QGeoTiledMappingManagerEnginebeeCopterLog)

class QNetworkAccessManager;

class QGeoTiledMappingManagerEnginebeeCopter : public QGeoTiledMappingManagerEngine
{
    Q_OBJECT

public:
    QGeoTiledMappingManagerEnginebeeCopter(const QVariantMap &parameters, QGeoServiceProvider::Error *error, QString *errorString, QNetworkAccessManager *networkManager = nullptr, QObject *parent = nullptr);
    ~QGeoTiledMappingManagerEnginebeeCopter();

    QGeoMap* createMap() final;
    QNetworkAccessManager *networkManager() const { return m_networkManager; }

private:
    QNetworkAccessManager *m_networkManager = nullptr;

    static constexpr int kTileVersion = 1;
};
