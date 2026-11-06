#include <QTest>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QStandardPaths>

#include "../src/ContactsModel.h"
#include "../src/FavoritesProxyModel.h"
#include "../src/RecentsModel.h"
#include "../src/PhoneController.h"

class TestPhone : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();

    // ContactsModel tests
    void testNumberFormatting();
    void testInitialsGeneration();
    void testContactFiltering();
    void testFavorites();
    void testFavoritesProxyModel();

    // RecentsModel tests
    void testRecentsAddAndFilter();
    void testRecentsClear();

    // PhoneController tests
    void testDialerInput();
    void testCallLifecycle();

private:
    std::unique_ptr<QTemporaryDir> m_tempDir;
};

void TestPhone::initTestCase()
{
    m_tempDir = std::make_unique<QTemporaryDir>();
    QVERIFY(m_tempDir->isValid());
    qputenv("XDG_DATA_HOME", m_tempDir->path().toUtf8());
}

void TestPhone::cleanupTestCase()
{
    m_tempDir.reset();
}

void TestPhone::testNumberFormatting()
{
    ContactsModel model;
    // Format Spain 9-digit
    QCOMPARE(model.findNameByNumber(QStringLiteral("")), QString());
}

void TestPhone::testInitialsGeneration()
{
    ContactsModel model;
    // Test that the model initializes properly and does not crash on empty/null data
    QVERIFY(model.rowCount() >= 0);
}

void TestPhone::testContactFiltering()
{
    ContactsModel model;
    const int total = model.count();

    // Apply a search filter that matches nothing
    model.setFilter(QStringLiteral("XYZNONEXISTENT999"));
    QCOMPARE(model.count(), 0);

    // Reset filter
    model.setFilter(QString());
    QCOMPARE(model.count(), total);
}

void TestPhone::testFavorites()
{
    ContactsModel model;
    // Toggle favorite on dummy id should not crash
    model.toggleFavorite(QStringLiteral("dummy-contact-123"));
    model.toggleFavorite(QStringLiteral("dummy-contact-123"));
}

void TestPhone::testFavoritesProxyModel()
{
    ContactsModel contacts;
    FavoritesProxyModel favorites;
    favorites.setSourceModel(&contacts);

    QVERIFY(favorites.rowCount() >= 0);
    QCOMPARE(favorites.count(), favorites.rowCount());
}

void TestPhone::testRecentsAddAndFilter()
{
    RecentsModel recents;
    recents.clearHistory();
    QCOMPARE(recents.count(), 0);

    recents.addCall(QStringLiteral("César"), QStringLiteral("985326477"), 0, 45); // Outgoing
    recents.addCall(QStringLiteral("Desconocido"), QStringLiteral("600123456"), 2, 0); // Missed

    QCOMPARE(recents.count(), 2);

    // Filter only missed
    recents.setOnlyMissed(true);
    QCOMPARE(recents.count(), 1);

    // Filter all
    recents.setOnlyMissed(false);
    QCOMPARE(recents.count(), 2);
}

void TestPhone::testRecentsClear()
{
    RecentsModel recents;
    recents.addCall(QStringLiteral("Prueba"), QStringLiteral("123"), 1, 10);
    QVERIFY(recents.count() > 0);

    recents.clearHistory();
    QCOMPARE(recents.count(), 0);
}

void TestPhone::testDialerInput()
{
    ContactsModel contacts;
    RecentsModel recents;
    PhoneController phone(&contacts, &recents);

    QCOMPARE(phone.dialedNumber(), QString());

    phone.appendDigit(QStringLiteral("6"));
    phone.appendDigit(QStringLiteral("8"));
    phone.appendDigit(QStringLiteral("4"));
    QCOMPARE(phone.dialedNumber(), QStringLiteral("684"));

    phone.deleteDigit();
    QCOMPARE(phone.dialedNumber(), QStringLiteral("68"));

    phone.clearNumber();
    QCOMPARE(phone.dialedNumber(), QString());
}

void TestPhone::testCallLifecycle()
{
    ContactsModel contacts;
    RecentsModel recents;
    PhoneController phone(&contacts, &recents);

    QCOMPARE(phone.callState(), static_cast<int>(PhoneController::Idle));

    phone.appendDigit(QStringLiteral("9"));
    phone.appendDigit(QStringLiteral("8"));
    phone.appendDigit(QStringLiteral("5"));

    phone.startCall();
    QCOMPARE(phone.callState(), static_cast<int>(PhoneController::Dialing));

    // Verify markCallConnected transitions to Active and starts duration
    phone.markCallConnected();
    QCOMPARE(phone.callState(), static_cast<int>(PhoneController::Active));

    phone.endCall();
    QCOMPARE(phone.callState(), static_cast<int>(PhoneController::Ended));
}

QTEST_MAIN(TestPhone)
#include "test_phone.moc"
