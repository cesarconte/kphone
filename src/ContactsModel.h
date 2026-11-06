#pragma once

#include <QAbstractListModel>
#include <QStringList>
#include <QVector>
#include <QSet>

struct ContactItem
{
    QString id;
    QString name;
    QString number;
    QString formattedNumber;
    QString email;
    QString initials;
    QString avatarColor;
    QString photoData; // base64 or empty
    bool isFavorite{false};
};

class ContactsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)

public:
    enum ContactRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        NumberRole,
        FormattedNumberRole,
        EmailRole,
        InitialsRole,
        AvatarColorRole,
        PhotoRole,
        IsFavoriteRole
    };

    explicit ContactsModel(QObject *parent = nullptr);
    ~ContactsModel() override = default;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const;
    QString filter() const;
    void setFilter(const QString &query);

    Q_INVOKABLE void reload();
    Q_INVOKABLE void toggleFavorite(const QString &contactId);
    Q_INVOKABLE QString findNameByNumber(const QString &number) const;

signals:
    void countChanged();
    void filterChanged();

private:
    void loadFromVcards();
    void loadFavorites();
    void saveFavorites();
    void applyFilter();
    static QString formatPhoneNumber(const QString &raw);
    static QString generateInitials(const QString &name);
    static QString pickAvatarColor(const QString &name);

    QVector<ContactItem> m_allContacts;
    QVector<ContactItem> m_filteredContacts;
    QSet<QString> m_favorites;
    QString m_filter;
};
