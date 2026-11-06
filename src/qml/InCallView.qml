import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Rectangle {
    id: root
    color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1C1C1E" : "#F2F2F7"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Item { Layout.fillHeight: true; Layout.preferredHeight: 20 }

        // Large Caller Avatar
        Rectangle {
            width: 88
            height: 88
            radius: 44
            color: "#34C759"
            Layout.alignment: Qt.AlignHCenter

            Kirigami.Icon {
                source: "user-identity"
                width: 48
                height: 48
                color: "white"
                anchors.centerIn: parent
            }
        }

        // Caller Info
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Text {
                text: phoneController.activeContactName.length > 0 ? phoneController.activeContactName : phoneController.formattedNumber
                font.pixelSize: 22
                font.weight: Font.Bold
                color: Kirigami.Theme.textColor
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: {
                    if (phoneController.callState === 1) return i18n("Marcando...");
                    if (phoneController.callState === 2) return i18n("Llamada entrante...");
                    if (phoneController.callState === 3) return phoneController.formattedDuration;
                    if (phoneController.callState === 4) return i18n("Llamada finalizada");
                    return "";
                }
                font.pixelSize: phoneController.callState === 3 ? 18 : 14
                font.weight: phoneController.callState === 3 ? Font.Bold : Font.Normal
                color: phoneController.callState === 4 ? "#FF3B30" : (phoneController.callState === 3 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor)
                Layout.alignment: Qt.AlignHCenter
            }

            // Subtitle hint while Dialing
            Rectangle {
                visible: phoneController.callState === 1
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 28
                radius: 14
                color: hintMouse.pressed ? "#48484A" : (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA")
                Layout.preferredWidth: hintLayout.implicitWidth + 24

                RowLayout {
                    id: hintLayout
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 6; height: 6; radius: 3; color: "#34C759"
                    }

                    Text {
                        text: phoneController.connectedDeviceName.length > 0 
                            ? i18n("Inicia la llamada en tu %1", phoneController.connectedDeviceName) 
                            : i18n("Pulsa para activar contador")
                        font.pixelSize: 11
                        color: Kirigami.Theme.textColor
                    }
                }

                MouseArea {
                    id: hintMouse
                    anchors.fill: parent
                    onClicked: phoneController.markCallConnected()
                }
            }
        }

        Item { Layout.fillHeight: true }

        // In-call Control Buttons Grid 2x3
        GridLayout {
            columns: 3
            columnSpacing: 28
            rowSpacing: 18
            Layout.alignment: Qt.AlignHCenter

            // 1. Silenciar (Mute)
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: phoneController.isMuted ? "white" : (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA")
                    Kirigami.Icon {
                        source: phoneController.isMuted ? "audio-volume-muted" : "audio-input-microphone"
                        width: 26; height: 26
                        color: phoneController.isMuted ? "black" : Kirigami.Theme.textColor
                        anchors.centerIn: parent
                    }
                    MouseArea { anchors.fill: parent; onClicked: phoneController.toggleMute() }
                }
                Text { text: i18n("Silenciar"); font.pixelSize: 11; color: Kirigami.Theme.textColor; Layout.alignment: Qt.AlignHCenter }
            }

            // 2. Teclado DTMF
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA"
                    Kirigami.Icon {
                        source: "input-dialpad"
                        width: 26; height: 26
                        color: Kirigami.Theme.textColor
                        anchors.centerIn: parent
                    }
                    MouseArea { 
                        anchors.fill: parent
                        onClicked: mainTabBar.currentIndex = 3 // Switch to Keypad tab
                    }
                }
                Text { text: i18n("Teclado"); font.pixelSize: 11; color: Kirigami.Theme.textColor; Layout.alignment: Qt.AlignHCenter }
            }

            // 3. Altavoz
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: phoneController.isSpeakerOn ? "white" : (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA")
                    Kirigami.Icon {
                        source: "audio-speakers"
                        width: 26; height: 26
                        color: phoneController.isSpeakerOn ? "black" : Kirigami.Theme.textColor
                        anchors.centerIn: parent
                    }
                    MouseArea { anchors.fill: parent; onClicked: phoneController.toggleSpeaker() }
                }
                Text { text: i18n("Altavoz"); font.pixelSize: 11; color: Kirigami.Theme.textColor; Layout.alignment: Qt.AlignHCenter }
            }

            // 4. Phone Mirroring Shortcut
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: "#5856D6"
                    Kirigami.Icon {
                        source: "kphonemirroring"
                        width: 26; height: 26
                        color: "white"
                        anchors.centerIn: parent
                    }
                    MouseArea { 
                        anchors.fill: parent
                        onClicked: phoneController.openPhoneMirroring()
                    }
                }
                Text { text: i18n("Pantalla"); font.pixelSize: 11; color: Kirigami.Theme.textColor; Layout.alignment: Qt.AlignHCenter }
            }

            // 5. Mensaje rápido
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA"
                    Kirigami.Icon {
                        source: "message-new"
                        width: 24; height: 24
                        color: Kirigami.Theme.textColor
                        anchors.centerIn: parent
                    }
                    MouseArea { 
                        anchors.fill: parent
                        onClicked: phoneController.openSms(phoneController.dialedNumber)
                    }
                }
                Text { text: i18n("Mensaje"); font.pixelSize: 11; color: Kirigami.Theme.textColor; Layout.alignment: Qt.AlignHCenter }
            }

            // 6. Contactos
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA"
                    Kirigami.Icon {
                        source: "contact-new"
                        width: 24; height: 24
                        color: Kirigami.Theme.textColor
                        anchors.centerIn: parent
                    }
                    MouseArea { 
                        anchors.fill: parent
                        onClicked: mainTabBar.currentIndex = 2 // Switch to Contacts tab
                    }
                }
                Text { text: i18n("Contactos"); font.pixelSize: 11; color: Kirigami.Theme.textColor; Layout.alignment: Qt.AlignHCenter }
            }
        }

        Item { Layout.fillHeight: true }

        // End Call Button (Big Red Circle)
        Rectangle {
            width: 68
            height: 68
            radius: 34
            color: endMouse.pressed ? "#D32F2F" : "#FF3B30"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 16

            Kirigami.Icon {
                source: "call-start"
                width: 32
                height: 32
                color: "#FFFFFF"
                isMask: true
                rotation: 135
                anchors.centerIn: parent
            }

            MouseArea {
                id: endMouse
                anchors.fill: parent
                onClicked: phoneController.endCall()
            }
        }
    }
}
