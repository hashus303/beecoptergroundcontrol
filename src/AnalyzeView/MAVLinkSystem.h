#pragma once

#include <QtCore/QLoggingCategory>
#include <QtCore/QObject>
#include <QtCore/QStringList>
#include <QtQmlIntegration/QtQmlIntegration>

#include "QmlObjectListModel.h"

Q_DECLARE_LOGGING_CATEGORY(MAVLinkSystemLog)

class beeCopterMAVLinkMessage;

class beeCopterMAVLinkSystem : public QObject
{
    Q_OBJECT
    // QML_ELEMENT
    Q_PROPERTY(quint8               id          READ id                             CONSTANT)
    Q_PROPERTY(QmlObjectListModel   *messages   READ messages                       CONSTANT)
    Q_PROPERTY(QList<int>           compIDs     READ compIDs                        NOTIFY compIDsChanged)
    Q_PROPERTY(QStringList          compIDsStr  READ compIDsStr                     NOTIFY compIDsChanged)
    Q_PROPERTY(int                  selected    READ selected   WRITE setSelected   NOTIFY selectedChanged)
public:
    beeCopterMAVLinkSystem(quint8 id, QObject *parent = nullptr);
    ~beeCopterMAVLinkSystem();

    quint8 id() const { return _systemID; }
    QmlObjectListModel *messages() const { return _messages; }
    QList<int> compIDs() const { return _compIDs; }
    QStringList compIDsStr() const { return _compIDsStr; }
    int selected() const { return _selected; }

    void setSelected(int sel);
    beeCopterMAVLinkMessage *findMessage(uint32_t id, uint8_t compId);
    int findMessage(const beeCopterMAVLinkMessage *message);
    void append(beeCopterMAVLinkMessage *message);
    beeCopterMAVLinkMessage *selectedMsg();

signals:
    void compIDsChanged();
    void selectedChanged();

private:
    void _checkCompID(const beeCopterMAVLinkMessage *message);
    void _resetSelection();

private:
    quint8 _systemID = 0;
    QmlObjectListModel *_messages = nullptr; ///< List of beeCopterMAVLinkMessage
    QList<int> _compIDs;
    QStringList _compIDsStr;
    int _selected = 0;
};
