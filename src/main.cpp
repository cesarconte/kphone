#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QCommandLineParser>
#include <QLoggingCategory>
#include <KLocalizedString>
#include <KLocalizedQmlContext>
#include <KAboutData>

#include "PhoneController.h"
#include "ContactsModel.h"
#include "FavoritesProxyModel.h"
#include "RecentsModel.h"

int main(int argc, char *argv[])
{
    // Configure Intel VA-API hardware backend and suppress unnecessary video decoding stderr logs for pure audio telephony
    qputenv("LIBVA_DRIVER_NAME", "iHD");
    QLoggingCategory::setFilterRules(QStringLiteral("qt.multimedia.ffmpeg.warning=false\nqt.multimedia.ffmpeg.debug=false\nqt.multimedia.ffmpeg=false"));

    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("kphone"));
    app.setApplicationDisplayName(QStringLiteral("Teléfono"));
    app.setOrganizationDomain(QStringLiteral("cesar.org"));
    app.setOrganizationName(QStringLiteral("Cesar"));
    app.setWindowIcon(QIcon(QStringLiteral(":/resources/icons/kphone.svg")));

    KLocalizedString::setApplicationDomain("kphone");

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("macOS-style Phone App & Dialer for KDE Plasma 6"));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument(QStringLiteral("url_or_number"), QStringLiteral("Phone number or tel: URL to dial"));
    parser.process(app);

    auto *contactsModel = new ContactsModel(&app);
    auto *favoritesModel = new FavoritesProxyModel(&app);
    favoritesModel->setSourceModel(contactsModel);

    auto *recentsModel = new RecentsModel(&app);
    auto *phoneController = new PhoneController(contactsModel, recentsModel, &app);

    // Check positional argument for immediate dial
    const QStringList positionalArgs = parser.positionalArguments();
    if (!positionalArgs.isEmpty()) {
        QString target = positionalArgs.first();
        if (target.startsWith(QStringLiteral("tel:"), Qt::CaseInsensitive)) {
            target = target.mid(4);
        }
        for (const QChar &ch : target) {
            if (ch.isDigit() || ch == QLatin1Char('+')) {
                phoneController->appendDigit(QString(ch));
            }
        }
    }

    QQmlApplicationEngine engine;
    KLocalization::setupLocalizedContext(&engine);
    engine.rootContext()->setContextProperty(QStringLiteral("contactsModel"), contactsModel);
    engine.rootContext()->setContextProperty(QStringLiteral("favoritesModel"), favoritesModel);
    engine.rootContext()->setContextProperty(QStringLiteral("recentsModel"), recentsModel);
    engine.rootContext()->setContextProperty(QStringLiteral("phoneController"), phoneController);

    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
