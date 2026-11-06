#pragma once

#include <QObject>
#include <QString>
#include <QTimer>
#include <memory>
#include "DtmfGenerator.h"

class ContactsModel;
class RecentsModel;

class PhoneController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString dialedNumber READ dialedNumber NOTIFY dialedNumberChanged)
    Q_PROPERTY(QString formattedNumber READ formattedNumber NOTIFY formattedNumberChanged)
    Q_PROPERTY(int callState READ callState NOTIFY callStateChanged)
    Q_PROPERTY(int callDuration READ callDuration NOTIFY callDurationChanged)
    Q_PROPERTY(QString formattedDuration READ formattedDuration NOTIFY callDurationChanged)
    Q_PROPERTY(QString activeContactName READ activeContactName NOTIFY activeContactNameChanged)
    Q_PROPERTY(bool isMuted READ isMuted NOTIFY isMutedChanged)
    Q_PROPERTY(bool isSpeakerOn READ isSpeakerOn NOTIFY isSpeakerOnChanged)
    Q_PROPERTY(QString connectedDeviceName READ connectedDeviceName NOTIFY deviceStatusChanged)
    Q_PROPERTY(bool isDeviceConnected READ isDeviceConnected NOTIFY deviceStatusChanged)
    Q_PROPERTY(int deviceBattery READ deviceBattery NOTIFY deviceStatusChanged)

public:
    enum CallState {
        Idle = 0,
        Dialing = 1,
        Ringing = 2,
        Active = 3,
        Ended = 4
    };
    Q_ENUM(CallState)

    explicit PhoneController(ContactsModel *contacts, RecentsModel *recents, QObject *parent = nullptr);
    ~PhoneController() override = default;

    QString dialedNumber() const;
    QString formattedNumber() const;
    int callState() const;
    int callDuration() const;
    QString formattedDuration() const;
    QString activeContactName() const;
    bool isMuted() const;
    bool isSpeakerOn() const;
    QString connectedDeviceName() const;
    bool isDeviceConnected() const;
    int deviceBattery() const;

    Q_INVOKABLE void appendDigit(const QString &digit);
    Q_INVOKABLE void deleteDigit();
    Q_INVOKABLE void clearNumber();
    Q_INVOKABLE void startCall(const QString &targetNumber = QString());
    Q_INVOKABLE void markCallConnected();
    Q_INVOKABLE void endCall();
    Q_INVOKABLE void answerCall();
    Q_INVOKABLE void toggleMute();
    Q_INVOKABLE void toggleSpeaker();
    Q_INVOKABLE void openPhoneMirroring();
    Q_INVOKABLE void openSms(const QString &number);
    Q_INVOKABLE void playDtmf(const QString &digit);
    Q_INVOKABLE void copyToClipboard(const QString &text);

signals:
    void dialedNumberChanged();
    void formattedNumberChanged();
    void callStateChanged();
    void callDurationChanged();
    void activeContactNameChanged();
    void isMutedChanged();
    void isSpeakerOnChanged();
    void deviceStatusChanged();
    void incomingCallReceived(const QString &number, const QString &name);

private slots:
    void onCallTimerTick();
    void updateKdeConnectStatus();
    void onTelephonyCallReceived(const QString &event, const QString &number, const QString &contactName);

private:
    void setCallState(CallState state);
    void setupKdeConnectDbus();
    static QString formatNumber(const QString &raw);

    ContactsModel *m_contactsModel{nullptr};
    RecentsModel *m_recentsModel{nullptr};
    std::unique_ptr<DtmfGenerator> m_dtmf;

    QString m_dialedNumber;
    CallState m_callState{Idle};
    int m_callDuration{0};
    QString m_activeContactName;
    bool m_isMuted{false};
    bool m_isSpeakerOn{false};

    QString m_connectedDeviceId;
    QString m_connectedDeviceName;
    bool m_isDeviceConnected{false};
    int m_deviceBattery{-1};

    QTimer m_callTimer;
    QTimer m_devicePollTimer;
};
