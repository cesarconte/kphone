#include "DtmfGenerator.h"
#include <QMediaDevices>
#include <QAudioDevice>
#include <cmath>

static constexpr int SAMPLE_RATE = 44100;
static constexpr double PI = 3.14159265358979323846;

DtmfGenerator::DtmfGenerator(QObject *parent)
    : QObject(parent)
{
    // Dual Tone Multi-Frequency standard ITU-T Q.23
    // Low frequencies: 697, 770, 852, 941
    // High frequencies: 1209, 1336, 1477
    m_frequencies["1"] = {697.0, 1209.0};
    m_frequencies["2"] = {697.0, 1336.0};
    m_frequencies["3"] = {697.0, 1477.0};
    m_frequencies["4"] = {770.0, 1209.0};
    m_frequencies["5"] = {770.0, 1336.0};
    m_frequencies["6"] = {770.0, 1477.0};
    m_frequencies["7"] = {852.0, 1209.0};
    m_frequencies["8"] = {852.0, 1336.0};
    m_frequencies["9"] = {852.0, 1477.0};
    m_frequencies["*"] = {941.0, 1209.0};
    m_frequencies["0"] = {941.0, 1336.0};
    m_frequencies["#"] = {941.0, 1477.0};

    initAudio();
}

DtmfGenerator::~DtmfGenerator()
{
    if (m_audioSink) {
        m_audioSink->stop();
    }
}

void DtmfGenerator::initAudio()
{
    m_format.setSampleRate(SAMPLE_RATE);
    m_format.setChannelCount(1);
    m_format.setSampleFormat(QAudioFormat::Int16);

    const QAudioDevice defaultDevice = QMediaDevices::defaultAudioOutput();
    if (!defaultDevice.isNull()) {
        m_audioSink = std::make_unique<QAudioSink>(defaultDevice, m_format, this);
        m_audioSink->setVolume(0.35f); // Comfortable volume
    }
}

QByteArray DtmfGenerator::generateTonePcm(double freq1, double freq2, int durationMs)
{
    const int totalSamples = (SAMPLE_RATE * durationMs) / 1000;
    const int rampSamples = (SAMPLE_RATE * 8) / 1000; // 8ms linear fade in/out to prevent clicks

    QByteArray pcm;
    pcm.resize(totalSamples * sizeof(qint16));
    auto *data = reinterpret_cast<qint16 *>(pcm.data());

    for (int i = 0; i < totalSamples; ++i) {
        const double t = static_cast<double>(i) / SAMPLE_RATE;
        const double s1 = std::sin(2.0 * PI * freq1 * t);
        const double s2 = std::sin(2.0 * PI * freq2 * t);
        double sample = 0.5 * (s1 + s2);

        // Apply envelope
        if (i < rampSamples) {
            sample *= static_cast<double>(i) / rampSamples;
        } else if (i > totalSamples - rampSamples) {
            sample *= static_cast<double>(totalSamples - i) / rampSamples;
        }

        data[i] = static_cast<qint16>(sample * 30000.0);
    }

    return pcm;
}

void DtmfGenerator::playTone(const QString &key)
{
    if (!m_frequencies.contains(key) || !m_audioSink) {
        return;
    }

    const auto freqs = m_frequencies[key];
    const QByteArray pcm = generateTonePcm(freqs.first, freqs.second, 120);

    if (m_buffer) {
        m_buffer->close();
    }

    m_buffer = std::make_unique<QBuffer>(this);
    m_buffer->setData(pcm);
    m_buffer->open(QIODevice::ReadOnly);

    m_audioSink->stop();
    m_audioSink->start(m_buffer.get());
}
