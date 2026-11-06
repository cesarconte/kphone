#include "ContactsModel.h"
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QCryptographicHash>
#include <algorithm>

ContactsModel::ContactsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    loadFavorites();
    loadFromVcards();
}

int ContactsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_filteredContacts.size();
}

QVariant ContactsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_filteredContacts.size()) {
        return {};
    }

    const auto &c = m_filteredContacts[index.row()];
    switch (role) {
    case IdRole: return c.id;
    case NameRole: return c.name;
    case NumberRole: return c.number;
    case FormattedNumberRole: return c.formattedNumber;
    case EmailRole: return c.email;
    case InitialsRole: return c.initials;
    case AvatarColorRole: return c.avatarColor;
    case PhotoRole: return c.photoData;
    case IsFavoriteRole: return c.isFavorite;
    default: return {};
    }
}

QHash<int, QByteArray> ContactsModel::roleNames() const
{
    return {
        {IdRole, "id"},
        {NameRole, "name"},
        {NumberRole, "number"},
        {FormattedNumberRole, "formattedNumber"},
        {EmailRole, "email"},
        {InitialsRole, "initials"},
        {AvatarColorRole, "avatarColor"},
        {PhotoRole, "photoData"},
        {IsFavoriteRole, "isFavorite"}
    };
}

int ContactsModel::count() const
{
    return m_filteredContacts.size();
}

QString ContactsModel::filter() const
{
    return m_filter;
}

void ContactsModel::setFilter(const QString &query)
{
    if (m_filter != query) {
        m_filter = query;
        applyFilter();
        Q_EMIT filterChanged();
    }
}

void ContactsModel::reload()
{
    loadFavorites();
    loadFromVcards();
}

void ContactsModel::toggleFavorite(const QString &contactId)
{
    for (auto &c : m_allContacts) {
        if (c.id == contactId) {
            c.isFavorite = !c.isFavorite;
            if (c.isFavorite) {
                m_favorites.insert(contactId);
            } else {
                m_favorites.remove(contactId);
            }
            break;
        }
    }
    saveFavorites();
    applyFilter();
}

QString ContactsModel::findNameByNumber(const QString &number) const
{
    if (number.isEmpty()) return {};
    QString cleanQuery = number;
    cleanQuery.remove(QRegularExpression("[^0-9+]"));

    for (const auto &c : m_allContacts) {
        QString cleanNum = c.number;
        cleanNum.remove(QRegularExpression("[^0-9+]"));
        if (!cleanNum.isEmpty() && (cleanNum.endsWith(cleanQuery) || cleanQuery.endsWith(cleanNum))) {
            return c.name;
        }
    }
    return {};
}

void ContactsModel::loadFavorites()
{
    m_favorites.clear();
    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QFile file(dataDir + QStringLiteral("/favorites.json"));
    if (file.open(QIODevice::ReadOnly)) {
        const auto doc = QJsonDocument::fromJson(file.readAll());
        if (doc.isArray()) {
            for (const auto &val : doc.array()) {
                m_favorites.insert(val.toString());
            }
        }
    }
}

void ContactsModel::saveFavorites()
{
    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataDir);
    QFile file(dataDir + QStringLiteral("/favorites.json"));
    if (file.open(QIODevice::WriteOnly)) {
        QJsonArray arr;
        for (const auto &id : m_favorites) {
            arr.append(id);
        }
        file.write(QJsonDocument(arr).toJson(QJsonDocument::Compact));
    }
}

void ContactsModel::loadFromVcards()
{
    m_allContacts.clear();

    const QString homePath = QDir::homePath();
    const QString kpeoplePath = homePath + QStringLiteral("/.local/share/kpeoplevcard");

    QDir dir(kpeoplePath);
    if (dir.exists()) {
        QDirIterator it(kpeoplePath, QStringList() << QStringLiteral("*.vcf"), QDir::Files, QDirIterator::Subdirectories);
        while (it.hasNext()) {
            const QString filePath = it.next();
            QFile file(filePath);
            if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                continue;
            }

            ContactItem item;
            item.id = QFileInfo(filePath).fileName();

            QString currentPhotoBase64;
            bool readingPhoto = false;

            QTextStream in(&file);
            while (!in.atEnd()) {
                QString line = in.readLine();
                if (readingPhoto) {
                    if (line.startsWith(QLatin1Char(' ')) || line.startsWith(QLatin1Char('\t'))) {
                        currentPhotoBase64.append(line.trimmed());
                        continue;
                    } else {
                        readingPhoto = false;
                        item.photoData = currentPhotoBase64;
                    }
                }

                if (line.startsWith(QStringLiteral("FN:"), Qt::CaseInsensitive)) {
                    item.name = line.mid(3).trimmed();
                } else if (line.startsWith(QStringLiteral("TEL"), Qt::CaseInsensitive)) {
                    const int colon = line.indexOf(QLatin1Char(':'));
                    if (colon != -1 && item.number.isEmpty()) {
                        item.number = line.mid(colon + 1).trimmed();
                    }
                } else if (line.startsWith(QStringLiteral("EMAIL"), Qt::CaseInsensitive)) {
                    const int colon = line.indexOf(QLatin1Char(':'));
                    if (colon != -1 && item.email.isEmpty()) {
                        item.email = line.mid(colon + 1).trimmed();
                    }
                } else if (line.startsWith(QStringLiteral("PHOTO"), Qt::CaseInsensitive)) {
                    const int colon = line.indexOf(QLatin1Char(':'));
                    if (colon != -1) {
                        currentPhotoBase64 = line.mid(colon + 1).trimmed();
                        readingPhoto = true;
                    }
                }
            }

            if (readingPhoto && !currentPhotoBase64.isEmpty()) {
                item.photoData = currentPhotoBase64;
            }

            if (!item.name.isEmpty() || !item.number.isEmpty()) {
                if (item.name.isEmpty()) {
                    item.name = item.number;
                }
                item.formattedNumber = formatPhoneNumber(item.number);
                item.initials = generateInitials(item.name);
                item.avatarColor = pickAvatarColor(item.name);
                item.isFavorite = m_favorites.contains(item.id);
                m_allContacts.append(item);
            }
        }
    }

    // Sort alphabetically by name
    std::sort(m_allContacts.begin(), m_allContacts.end(), [](const ContactItem &a, const ContactItem &b) {
        return a.name.localeAwareCompare(b.name) < 0;
    });

    applyFilter();
    Q_EMIT countChanged();
}

void ContactsModel::applyFilter()
{
    beginResetModel();
    m_filteredContacts.clear();
    const QString cleanFilter = m_filter.trimmed();

    for (const auto &c : m_allContacts) {
        if (cleanFilter.isEmpty()
            || c.name.contains(cleanFilter, Qt::CaseInsensitive)
            || c.number.contains(cleanFilter, Qt::CaseInsensitive)
            || c.email.contains(cleanFilter, Qt::CaseInsensitive)) {
            m_filteredContacts.append(c);
        }
    }
    endResetModel();
    Q_EMIT countChanged();
}

QString ContactsModel::formatPhoneNumber(const QString &raw)
{
    QString digits;
    for (const QChar &ch : raw) {
        if (ch.isDigit() || ch == QLatin1Char('+')) {
            digits.append(ch);
        }
    }

    // Format typical 9-digit Spanish mobile/landline numbers: XXX XX XX XX
    if (digits.length() == 9 && !digits.startsWith(QLatin1Char('+'))) {
        return QStringLiteral("%1 %2 %3 %4")
            .arg(digits.mid(0, 3), digits.mid(3, 2), digits.mid(5, 2), digits.mid(7, 2));
    }
    // E.164: +34 XXX XX XX XX
    if (digits.length() == 12 && digits.startsWith(QStringLiteral("+34"))) {
        return QStringLiteral("+34 %1 %2 %3 %4")
            .arg(digits.mid(3, 3), digits.mid(6, 2), digits.mid(8, 2), digits.mid(10, 2));
    }

    return raw;
}

QString ContactsModel::generateInitials(const QString &name)
{
    const QStringList parts = name.split(QLatin1Char(' '), Qt::SkipEmptyParts);
    if (parts.isEmpty()) return QStringLiteral("?");
    if (parts.size() == 1) return parts.first().left(1).toUpper();
    return (parts.first().left(1) + parts.last().left(1)).toUpper();
}

QString ContactsModel::pickAvatarColor(const QString &name)
{
    // Apple-inspired soft vibrant avatar colors
    static const QStringList colors = {
        QStringLiteral("#FF3B30"), // Coral Red
        QStringLiteral("#FF9500"), // Orange
        QStringLiteral("#FFCC00"), // Yellow
        QStringLiteral("#34C759"), // Green
        QStringLiteral("#007AFF"), // System Blue
        QStringLiteral("#5856D6"), // Indigo
        QStringLiteral("#AF52DE"), // Purple
        QStringLiteral("#FF2D55")  // Pink
    };

    const uint hash = qHash(name);
    return colors[hash % colors.size()];
}
