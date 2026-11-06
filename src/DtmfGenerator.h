#pragma once

#include <QObject>
#include <QAudioFormat>
#include <QAudioSink>
#include <QBuffer>
#include <QByteArray>
#include <QMap>
#include <QPair>
#include <memory>

class DtmfGenerator : public QObject
{
    Q_OBJECT

public:
    explicit DtmfGenerator(QObject *parent = nullptr);
    ~DtmfGenerator() override;

    void playTone(const QString &key);

private:
    void initAudio();
    QByteArray generateTonePcm(double freq1, double freq2, int durationMs = 120);

    QAudioFormat m_format;
    std::unique_ptr<QAudioSink> m_audioSink;
    std::unique_ptr<QBuffer> m_buffer;
    QMap<QString, QPair<double, double>> m_frequencies;
};
