#pragma once

#include <QSortFilterProxyModel>
#include "ContactsModel.h"

class FavoritesProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit FavoritesProxyModel(QObject *parent = nullptr)
        : QSortFilterProxyModel(parent)
    {
        connect(this, &QAbstractItemModel::rowsInserted, this, &FavoritesProxyModel::countChanged);
        connect(this, &QAbstractItemModel::rowsRemoved, this, &FavoritesProxyModel::countChanged);
        connect(this, &QAbstractItemModel::modelReset, this, &FavoritesProxyModel::countChanged);
        connect(this, &QAbstractItemModel::layoutChanged, this, &FavoritesProxyModel::countChanged);
    }

    int count() const {
        return rowCount();
    }

signals:
    void countChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override
    {
        const QModelIndex idx = sourceModel()->index(sourceRow, 0, sourceParent);
        return idx.data(ContactsModel::IsFavoriteRole).toBool();
    }
};
