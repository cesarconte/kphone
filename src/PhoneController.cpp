#include "PhoneController.h"
#include "ContactsModel.h"
#include "RecentsModel.h"
#include <QDesktopServices>
#include <QUrl>
#include <QProcess>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusMessage>
#include <QRegularExpression>
#include <QGuiApplication>
#include <QClipboard>

PhoneController::PhoneController(ContactsModel *contacts, RecentsModel *recents, QObject *parent)
    : QObject(parent)
    , m_contactsModel(contacts)
    , m_recentsModel(recents)
    , m_dtmf(std::make_unique<DtmfGenerator>(this))
{
    connect(&m_callTimer, &QTimer::timeout, this, &PhoneController::onCallTimerTick);
    m_callTimer.setInterval(1000);

    connect(&m_devicePollTimer, &QTimer::timeout, this, &PhoneController::updateKdeConnectStatus);
    m_devicePollTimer.start(5000); // Poll status every 5 seconds

    setupKdeConnectDbus();
    updateKdeConnectStatus();
}

QString PhoneController::dialedNumber() const
{
    return m_dialedNumber;
}

QString PhoneController::formattedNumber() const
{
    return formatNumber(m_dialedNumber);
}

int PhoneController::callState() const
{
    return static_cast<int>(m_callState);
}

int PhoneController::callDuration() const
{
    return m_callDuration;
}

QString PhoneController::formattedDuration() const
{
    const int mins = m_callDuration / 60;
    const int secs = m_callDuration % 60;
    return QStringLiteral("%1:%2").arg(mins, 2, 10, QLatin1Char('0')).arg(secs, 2, 10, QLatin1Char('0'));
}

QString PhoneController::activeContactName() const
{
    return m_activeContactName;
}

bool PhoneController::isMuted() const
{
    return m_isMuted;
}

bool PhoneController::isSpeakerOn() const
{
    return m_isSpeakerOn;
}

QString PhoneController::connectedDeviceName() const
{
    return m_connectedDeviceName;
}

bool PhoneController::isDeviceConnected() const
{
    return m_isDeviceConnected;
}

int PhoneController::deviceBattery() const
{
    return m_deviceBattery;
}

void PhoneController::appendDigit(const QString &digit)
{
    if (digit.isEmpty()) return;
    m_dialedNumber.append(digit);
    m_dtmf->playTone(digit);

    if (m_contactsModel) {
        m_activeContactName = m_contactsModel->findNameByNumber(m_dialedNumber);
        Q_EMIT activeContactNameChanged();
    }

    Q_EMIT dialedNumberChanged();
    Q_EMIT formattedNumberChanged();
}

void PhoneController::deleteDigit()
{
    if (!m_dialedNumber.isEmpty()) {
        m_dialedNumber.chop(1);
        if (m_contactsModel) {
            m_activeContactName = m_contactsModel->findNameByNumber(m_dialedNumber);
            Q_EMIT activeContactNameChanged();
        }
        Q_EMIT dialedNumberChanged();
        Q_EMIT formattedNumberChanged();
    }
}

void PhoneController::clearNumber()
{
    if (!m_dialedNumber.isEmpty()) {
        m_dialedNumber.clear();
        m_activeContactName.clear();
        Q_EMIT dialedNumberChanged();
        Q_EMIT formattedNumberChanged();
        Q_EMIT activeContactNameChanged();
    }
}

void PhoneController::playDtmf(const QString &digit)
{
    m_dtmf->playTone(digit);
}

void PhoneController::copyToClipboard(const QString &text)
{
    if (auto *cb = QGuiApplication::clipboard()) {
        cb->setText(text);
    }
}

void PhoneController::startCall(const QString &targetNumber)
{
    QString numberToCall = targetNumber.trimmed();
    if (numberToCall.isEmpty()) {
        numberToCall = m_dialedNumber.trimmed();
    }

    if (numberToCall.isEmpty()) {
        return;
    }

    m_dialedNumber = numberToCall;
    if (m_contactsModel) {
        m_activeContactName = m_contactsModel->findNameByNumber(numberToCall);
    }
    Q_EMIT dialedNumberChanged();
    Q_EMIT formattedNumberChanged();
    Q_EMIT activeContactNameChanged();

    // Dispatch directly via kdeconnect-handler to communicate with smartphone
    if (!QProcess::startDetached(QStringLiteral("kdeconnect-handler"), {QStringLiteral("tel:%1").arg(numberToCall)})) {
        QDesktopServices::openUrl(QUrl(QStringLiteral("tel:%1").arg(numberToCall)));
    }

    // Set state to Dialing (waiting for confirmation / connect on phone)
    setCallState(Dialing);
    m_callDuration = 0;
    Q_EMIT callDurationChanged();
}

void PhoneController::markCallConnected()
{
    if (m_callState == Dialing || m_callState == Ringing) {
        setCallState(Active);
        m_callDuration = 0;
        m_callTimer.start();
        Q_EMIT callDurationChanged();
    }
}

void PhoneController::endCall()
{
    if (m_callState == Idle) return;

    m_callTimer.stop();

    if (m_recentsModel && !m_dialedNumber.isEmpty()) {
        const int callType = (m_callState == Ringing && m_callDuration == 0) ? 2 : 0;
        m_recentsModel->addCall(m_activeContactName, m_dialedNumber, callType, m_callDuration);
    }

    setCallState(Ended);

    QTimer::singleShot(1200, this, [this]() {
        setCallState(Idle);
        m_callDuration = 0;
        Q_EMIT callDurationChanged();
    });
}

void PhoneController::answerCall()
{
    setCallState(Active);
    m_callDuration = 0;
    m_callTimer.start();
    Q_EMIT callDurationChanged();
}

void PhoneController::toggleMute()
{
    m_isMuted = !m_isMuted;
    Q_EMIT isMutedChanged();
}

void PhoneController::toggleSpeaker()
{
    m_isSpeakerOn = !m_isSpeakerOn;
    Q_EMIT isSpeakerOnChanged();
}

void PhoneController::openPhoneMirroring()
{
    if (QProcess::startDetached(QStringLiteral("kphonemirroring"), {})) {
        return;
    }
    QProcess::startDetached(QStringLiteral("scrcpy"), {QStringLiteral("--window-title"), QStringLiteral("iPhone Mirroring")});
}

void PhoneController::openSms(const QString &number)
{
    QDesktopServices::openUrl(QUrl(QStringLiteral("sms:%1").arg(number)));
}

void PhoneController::onCallTimerTick()
{
    m_callDuration++;
    Q_EMIT callDurationChanged();
}

void PhoneController::setCallState(CallState state)
{
    if (m_callState != state) {
        m_callState = state;
        Q_EMIT callStateChanged();
    }
}

void PhoneController::setupKdeConnectDbus()
{
    auto bus = QDBusConnection::sessionBus();
    bus.connect(
        QStringLiteral("org.kde.kdeconnect.daemon"),
        QStringLiteral("/modules/kdeconnect"),
        QStringLiteral("org.kde.kdeconnect.daemon"),
        QStringLiteral("deviceListChanged"),
        this,
        SLOT(updateKdeConnectStatus())
    );
}

void PhoneController::updateKdeConnectStatus()
{
    QDBusInterface daemonIface(
        QStringLiteral("org.kde.kdeconnect.daemon"),
        QStringLiteral("/modules/kdeconnect"),
        QStringLiteral("org.kde.kdeconnect.daemon"),
        QDBusConnection::sessionBus()
    );

    if (!daemonIface.isValid()) {
        m_isDeviceConnected = false;
        m_connectedDeviceName = QStringLiteral("Sin dispositivo");
        m_deviceBattery = -1;
        Q_EMIT deviceStatusChanged();
        return;
    }

    QDBusReply<QStringList> devicesReply = daemonIface.call(QStringLiteral("devices"), true, true);
    if (!devicesReply.isValid() || devicesReply.value().isEmpty()) {
        m_isDeviceConnected = false;
        m_connectedDeviceName = QStringLiteral("Sin teléfono vinculado");
        m_deviceBattery = -1;
        Q_EMIT deviceStatusChanged();
        return;
    }

    const QString devId = devicesReply.value().first();
    m_connectedDeviceId = devId;
    m_isDeviceConnected = true;

    // Get Device Name
    QDBusInterface devIface(
        QStringLiteral("org.kde.kdeconnect.daemon"),
        QStringLiteral("/modules/kdeconnect/devices/") + devId,
        QStringLiteral("org.kde.kdeconnect.device"),
        QDBusConnection::sessionBus()
    );
    if (devIface.isValid()) {
        m_connectedDeviceName = devIface.property("name").toString();
    }

    // Get Battery
    QDBusInterface batteryIface(
        QStringLiteral("org.kde.kdeconnect.daemon"),
        QStringLiteral("/modules/kdeconnect/devices/") + devId + QStringLiteral("/battery"),
        QStringLiteral("org.kde.kdeconnect.device.battery"),
        QDBusConnection::sessionBus()
    );
    if (batteryIface.isValid()) {
        m_deviceBattery = batteryIface.property("currentCharge").toInt();
    }

    // Hook telephony signal for this device
    QDBusConnection::sessionBus().connect(
        QStringLiteral("org.kde.kdeconnect.daemon"),
        QStringLiteral("/modules/kdeconnect/devices/") + devId + QStringLiteral("/telephony"),
        QStringLiteral("org.kde.kdeconnect.device.telephony"),
        QStringLiteral("callReceived"),
        this,
        SLOT(onTelephonyCallReceived(QString, QString, QString))
    );

    Q_EMIT deviceStatusChanged();
}

void PhoneController::onTelephonyCallReceived(const QString &event, const QString &number, const QString &contactName)
{
    if (event == QStringLiteral("ringing")) {
        m_dialedNumber = number;
        m_activeContactName = contactName.isEmpty() ? (m_contactsModel ? m_contactsModel->findNameByNumber(number) : QString()) : contactName;
        setCallState(Ringing);
        Q_EMIT incomingCallReceived(number, m_activeContactName);
        Q_EMIT dialedNumberChanged();
        Q_EMIT formattedNumberChanged();
        Q_EMIT activeContactNameChanged();
    } else if (event == QStringLiteral("talking")) {
        if (m_callState != Active) {
            setCallState(Active);
            m_callDuration = 0;
            m_callTimer.start();
            Q_EMIT callDurationChanged();
        }
    } else if (event == QStringLiteral("missedCall")) {
        if (m_recentsModel) {
            m_recentsModel->addCall(contactName, number, 2, 0); // 2 = Missed
        }
        endCall();
    } else if (event == QStringLiteral("callEnded") || event == QStringLiteral("idle")) {
        endCall();
    }
}

QString PhoneController::formatNumber(const QString &raw)
{
    QString digits;
    for (const QChar &ch : raw) {
        if (ch.isDigit() || ch == QLatin1Char('+')) {
            digits.append(ch);
        }
    }

    if (digits.length() == 9 && !digits.startsWith(QLatin1Char('+'))) {
        return QStringLiteral("%1 %2 %3 %4")
            .arg(digits.mid(0, 3), digits.mid(3, 2), digits.mid(5, 2), digits.mid(7, 2));
    }
    if (digits.length() == 12 && digits.startsWith(QStringLiteral("+34"))) {
        return QStringLiteral("+34 %1 %2 %3 %4")
            .arg(digits.mid(3, 3), digits.mid(6, 2), digits.mid(8, 2), digits.mid(10, 2));
    }
    return raw;
}
