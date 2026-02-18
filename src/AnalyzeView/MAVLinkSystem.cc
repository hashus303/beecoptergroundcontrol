#include "MAVLinkSystem.h"
#include "MAVLinkMessage.h"
#include "beeCopterLoggingCategory.h"

beeCopter_LOGGING_CATEGORY(MAVLinkSystemLog, "AnalyzeView.MAVLinkSystem")

beeCopterMAVLinkSystem::beeCopterMAVLinkSystem(quint8 id, QObject *parent)
    : QObject(parent)
    , _systemID(id)
    , _messages(new QmlObjectListModel(this))
{
    qCDebug(MAVLinkSystemLog) << "New Vehicle:" << id;
}

beeCopterMAVLinkSystem::~beeCopterMAVLinkSystem()
{
    _messages->clearAndDeleteContents();
}

beeCopterMAVLinkMessage *beeCopterMAVLinkSystem::findMessage(uint32_t id, uint8_t compId)
{
    for (int i = 0; i < _messages->count(); i++) {
        beeCopterMAVLinkMessage *const msg = qobject_cast<beeCopterMAVLinkMessage*>(_messages->get(i));
        if(msg) {
            if((msg->id() == id) && (msg->compId() == compId)) {
                return msg;
            }
        }
    }

    return nullptr;
}

int beeCopterMAVLinkSystem::findMessage(const beeCopterMAVLinkMessage *message)
{
    for (int i = 0; i < _messages->count(); i++) {
        const beeCopterMAVLinkMessage *const msg = qobject_cast<const beeCopterMAVLinkMessage*>(_messages->get(i));
        if (msg && (msg == message)) {
            return i;
        }
    }

    return -1;
}

void beeCopterMAVLinkSystem::_resetSelection()
{
    for (int i = 0; i < _messages->count(); i++) {
        beeCopterMAVLinkMessage *const msg = qobject_cast<beeCopterMAVLinkMessage*>(_messages->get(i));
        if (msg && msg->selected()) {
            msg->setSelected(false);
            emit msg->selectedChanged();
        }
    }
}

void beeCopterMAVLinkSystem::setSelected(int sel)
{
    if (sel >= _messages->count()) {
        return;
    }

    _selected = sel;
    emit selectedChanged();
    _resetSelection();
    beeCopterMAVLinkMessage *const msg = qobject_cast<beeCopterMAVLinkMessage*>(_messages->get(sel));
    if(msg && !msg->selected()) {
        msg->setSelected(true);
        emit msg->selectedChanged();
    }
}

beeCopterMAVLinkMessage *beeCopterMAVLinkSystem::selectedMsg()
{
    beeCopterMAVLinkMessage *selectedMsg = nullptr;
    if (_messages->count()) {
        selectedMsg = qobject_cast<beeCopterMAVLinkMessage*>(_messages->get(_selected));
    }

    return selectedMsg;
}

static bool messages_sort(const QObject *a, const QObject *b)
{
    const beeCopterMAVLinkMessage *const aa = qobject_cast<const beeCopterMAVLinkMessage*>(a);
    const beeCopterMAVLinkMessage *const bb = qobject_cast<const beeCopterMAVLinkMessage*>(b);
    if (!aa || !bb) {
        return false;
    }

    if (aa->name() == bb->name()) {
        return (aa->name() < bb->name());
    }

    return (aa->name() < bb->name());
}

void beeCopterMAVLinkSystem::append(beeCopterMAVLinkMessage *message)
{
    beeCopterMAVLinkMessage *selectedMsg = nullptr;
    if (_messages->count()) {
        selectedMsg = qobject_cast<beeCopterMAVLinkMessage*>(_messages->get(_selected));
    } else {
        message->setSelected(true);
    }
    _messages->append(message);

    if (_messages->count() > 0) {
        _messages->beginResetModel();
        std::sort(_messages->objectList()->begin(), _messages->objectList()->end(), messages_sort);
        _messages->endResetModel();
        _checkCompID(message);
    }

    if (selectedMsg) {
        const int idx = findMessage(selectedMsg);
        if (idx >= 0) {
            _selected = idx;
            emit selectedChanged();
        }
    }
}

void beeCopterMAVLinkSystem::_checkCompID(const beeCopterMAVLinkMessage *message)
{
    if (_compIDsStr.isEmpty()) {
        _compIDsStr << tr("Comp All");
    }

    if (!_compIDs.contains(static_cast<int>(message->compId()))) {
        const int compId = static_cast<int>(message->compId());
        _compIDs.append(compId);
        _compIDsStr << tr("Comp %1").arg(compId);
        emit compIDsChanged();
    }
}
