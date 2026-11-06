#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QVector>

struct RecentCallItem
{
    QString id;
    QString name;
    QString number;
    QString formattedNumber;
    int type; // 0: Outgoing, 1: Incoming, 2: Missed
    QDateTime timestamp;
    int durationSeconds{0};
};

class RecentsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int allCount READ allCount NOTIFY countChanged)
    Q_PROPERTY(int missedCount READ missedCount NOTIFY countChanged)
    Q_PROPERTY(bool onlyMissed READ onlyMissed WRITE setOnlyMissed NOTIFY onlyMissedChanged)

public:
    enum RecentRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        NumberRole,
        FormattedNumberRole,
        TypeRole,
        TimestampRole,
        FormattedDateRole,
        DurationRole
    };

    explicit RecentsModel(QObject *parent = nullptr);
    ~RecentsModel() override = default;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const;
    int allCount() const;
    int missedCount() const;
    bool onlyMissed() const;
    void setOnlyMissed(bool missed);

    Q_INVOKABLE void addCall(const QString &name, const QString &number, int type, int durationSeconds = 0);
    Q_INVOKABLE void clearHistory();
    Q_INVOKABLE void clearMissed();
    Q_INVOKABLE void clearCurrent();
    Q_INVOKABLE void removeAt(int row);
    Q_INVOKABLE void removeById(const QString &callId);

signals:
    void countChanged();
    void onlyMissedChanged();

private:
    void load();
    void save();
    void applyFilter();
    static QString formatCallDate(const QDateTime &dt);

    QVector<RecentCallItem> m_allCalls;
    QVector<RecentCallItem> m_filteredCalls;
    bool m_onlyMissed{false};
};
