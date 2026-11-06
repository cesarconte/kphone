#include "RecentsModel.h"
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QUuid>
#include <QDebug>

RecentsModel::RecentsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    load();
}

int RecentsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_filteredCalls.size();
}

QVariant RecentsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_filteredCalls.size()) {
        return {};
    }

    const auto &call = m_filteredCalls[index.row()];
    switch (role) {
    case IdRole: return call.id;
    case NameRole: return call.name;
    case NumberRole: return call.number;
    case FormattedNumberRole: return call.formattedNumber;
    case TypeRole: return call.type;
    case TimestampRole: return call.timestamp;
    case FormattedDateRole: return formatCallDate(call.timestamp);
    case DurationRole: {
        const int mins = call.durationSeconds / 60;
        const int secs = call.durationSeconds % 60;
        return QStringLiteral("%1:%2").arg(mins, 2, 10, QLatin1Char('0')).arg(secs, 2, 10, QLatin1Char('0'));
    }
    default: return {};
    }
}

QHash<int, QByteArray> RecentsModel::roleNames() const
{
    return {
        {IdRole, "callId"},
        {NameRole, "name"},
        {NumberRole, "number"},
        {FormattedNumberRole, "formattedNumber"},
        {TypeRole, "type"},
        {TimestampRole, "timestamp"},
        {FormattedDateRole, "formattedDate"},
        {DurationRole, "duration"}
    };
}

int RecentsModel::count() const
{
    return m_filteredCalls.size();
}

int RecentsModel::allCount() const
{
    return m_allCalls.size();
}

int RecentsModel::missedCount() const
{
    int missed = 0;
    for (const auto &call : m_allCalls) {
        if (call.type == 2) {
            missed++;
        }
    }
    return missed;
}

bool RecentsModel::onlyMissed() const
{
    return m_onlyMissed;
}

void RecentsModel::setOnlyMissed(bool missed)
{
    if (m_onlyMissed != missed) {
        m_onlyMissed = missed;
        beginResetModel();
        applyFilter();
        endResetModel();
        Q_EMIT onlyMissedChanged();
    }
}

void RecentsModel::addCall(const QString &name, const QString &number, int type, int durationSeconds)
{
    RecentCallItem item;
    item.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    item.name = name.isEmpty() ? number : name;
    item.number = number;
    item.formattedNumber = number;
    item.type = type;
    item.timestamp = QDateTime::currentDateTime();
    item.durationSeconds = durationSeconds;

    beginResetModel();
    m_allCalls.prepend(item);
    if (m_allCalls.size() > 200) {
        m_allCalls.resize(200);
    }
    applyFilter();
    endResetModel();

    save();
    Q_EMIT countChanged();
}

void RecentsModel::clearHistory()
{
    qDebug() << "RecentsModel::clearHistory called! Removing all" << m_allCalls.size() << "calls.";
    beginResetModel();
    m_allCalls.clear();
    m_filteredCalls.clear();
    endResetModel();
    save();
    Q_EMIT countChanged();
}

void RecentsModel::clearMissed()
{
    qDebug() << "RecentsModel::clearMissed called! Removing missed calls.";
    beginResetModel();
    m_allCalls.removeIf([](const RecentCallItem &c) {
        return c.type == 2;
    });
    applyFilter();
    endResetModel();
    save();
    Q_EMIT countChanged();
}

void RecentsModel::clearCurrent()
{
    if (m_onlyMissed) {
        clearMissed();
    } else {
        clearHistory();
    }
}

void RecentsModel::removeAt(int row)
{
    if (row < 0 || row >= m_filteredCalls.size()) {
        return;
    }

    const QString targetId = m_filteredCalls[row].id;
    qDebug() << "RecentsModel::removeAt called for row" << row << "id:" << targetId;
    removeById(targetId);
}

void RecentsModel::removeById(const QString &callId)
{
    if (callId.isEmpty()) {
        return;
    }

    qDebug() << "RecentsModel::removeById called for id:" << callId;
    beginResetModel();
    m_allCalls.removeIf([&callId](const RecentCallItem &c) {
        return c.id == callId;
    });
    applyFilter();
    endResetModel();
    save();
    Q_EMIT countChanged();
}

void RecentsModel::applyFilter()
{
    m_filteredCalls.clear();
    for (const auto &call : m_allCalls) {
        if (!m_onlyMissed || call.type == 2) {
            m_filteredCalls.append(call);
        }
    }
    Q_EMIT countChanged();
}

void RecentsModel::load()
{
    beginResetModel();
    m_allCalls.clear();

    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QFile file(dataDir + QStringLiteral("/recents.json"));
    if (file.open(QIODevice::ReadOnly)) {
        const auto doc = QJsonDocument::fromJson(file.readAll());
        if (doc.isArray()) {
            for (const auto &val : doc.array()) {
                const auto obj = val.toObject();
                RecentCallItem item;
                item.id = obj.value(QStringLiteral("id")).toString();
                if (item.id.isEmpty()) {
                    item.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
                }
                item.name = obj.value(QStringLiteral("name")).toString();
                item.number = obj.value(QStringLiteral("number")).toString();
                item.formattedNumber = item.number;
                item.type = obj.value(QStringLiteral("type")).toInt();
                item.timestamp = QDateTime::fromString(obj.value(QStringLiteral("timestamp")).toString(), Qt::ISODate);
                item.durationSeconds = obj.value(QStringLiteral("duration")).toInt();
                m_allCalls.append(item);
            }
        }
    }
    applyFilter();
    endResetModel();
    Q_EMIT countChanged();
}

void RecentsModel::save()
{
    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataDir);
    QFile file(dataDir + QStringLiteral("/recents.json"));
    if (file.open(QIODevice::WriteOnly)) {
        QJsonArray arr;
        for (const auto &call : m_allCalls) {
            QJsonObject obj;
            obj[QStringLiteral("id")] = call.id;
            obj[QStringLiteral("name")] = call.name;
            obj[QStringLiteral("number")] = call.number;
            obj[QStringLiteral("type")] = call.type;
            obj[QStringLiteral("timestamp")] = call.timestamp.toString(Qt::ISODate);
            obj[QStringLiteral("duration")] = call.durationSeconds;
            arr.append(obj);
        }
        file.write(QJsonDocument(arr).toJson(QJsonDocument::Compact));
    }
}

QString RecentsModel::formatCallDate(const QDateTime &dt)
{
    const QDate today = QDate::currentDate();
    if (dt.date() == today) {
        return dt.toString(QStringLiteral("hh:mm"));
    }
    if (dt.date() == today.addDays(-1)) {
        return QStringLiteral("Ayer");
    }
    if (dt.date().daysTo(today) < 7) {
        return dt.toString(QStringLiteral("dddd"));
    }
    return dt.toString(QStringLiteral("dd/MM/yy"));
}
