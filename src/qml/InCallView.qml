/*
 * SPDX-FileCopyrightText: 2026 Cesar
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root
    color: CachyPalette.contentBackground

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Item { Layout.fillHeight: true; Layout.preferredHeight: 20 }

        // Large Caller Avatar (macOS Golden Gate circular avatar)
        Rectangle {
            width: 88
            height: 88
            radius: 44
            color: "#34C759"
            border.width: 1
            border.color: CachyPalette.specularBorder
            Layout.alignment: Qt.AlignHCenter

            CachyIcon {
                name: "user-identity"
                size: 48
                color: "#FFFFFF"
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
                color: CachyPalette.text
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
                color: phoneController.callState === 4 ? "#FF3B30" : (phoneController.callState === 3 ? CachyTheme.accentColor : CachyPalette.textSecondary)
                Layout.alignment: Qt.AlignHCenter
            }

            // Subtitle hint while Dialing
            Rectangle {
                visible: phoneController.callState === 1
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 28
                radius: 14
                color: hintTap.pressed
                    ? CachyPalette.pressedOverlay
                    : (hintHover.hovered ? CachyPalette.cardBackgroundHover : (CachyPalette.isDark ? "#2C2C2E" : "#E5E5EA"))
                border.width: 1
                border.color: CachyPalette.specularBorder
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
                        color: CachyPalette.text
                    }
                }

                HoverHandler { id: hintHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    id: hintTap
                    onTapped: phoneController.markCallConnected()
                }
            }
        }

        Item { Layout.fillHeight: true }

        // In-call Control Buttons Grid 2x3 (macOS Golden Gate circular action cluster)
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
                    color: phoneController.isMuted
                        ? "#FFFFFF"
                        : (muteTap.pressed ? CachyPalette.pressedOverlay : (muteHover.hovered ? CachyPalette.cardBackgroundHover : (CachyPalette.isDark ? "#2C2C2E" : "#E5E5EA")))
                    border.width: 1
                    border.color: CachyPalette.specularBorder

                    scale: muteTap.pressed ? 0.94 : (muteHover.hovered ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutBack } }

                    CachyIcon {
                        name: phoneController.isMuted ? "audio-volume-muted" : "audio-input-microphone"
                        size: 26
                        color: phoneController.isMuted ? "black" : CachyPalette.text
                        anchors.centerIn: parent
                    }
                    HoverHandler { id: muteHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { id: muteTap; onTapped: phoneController.toggleMute() }

                    QQC2.ToolTip.visible: muteHover.hovered
                    QQC2.ToolTip.text: phoneController.isMuted ? i18n("Activar micrófono") : i18n("Silenciar")
                    QQC2.ToolTip.delay: 450
                }
                Text { text: i18n("Silenciar"); font.pixelSize: 11; color: CachyPalette.text; Layout.alignment: Qt.AlignHCenter }
            }

            // 2. Teclado DTMF
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: dtmfTap.pressed ? CachyPalette.pressedOverlay : (dtmfHover.hovered ? CachyPalette.cardBackgroundHover : (CachyPalette.isDark ? "#2C2C2E" : "#E5E5EA"))
                    border.width: 1
                    border.color: CachyPalette.specularBorder

                    scale: dtmfTap.pressed ? 0.94 : (dtmfHover.hovered ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutBack } }

                    CachyIcon {
                        name: "input-dialpad"
                        size: 26
                        color: CachyPalette.text
                        anchors.centerIn: parent
                    }
                    HoverHandler { id: dtmfHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        id: dtmfTap
                        onTapped: mainTabBar.currentIndex = 3 // Switch to Keypad tab
                    }

                    QQC2.ToolTip.visible: dtmfHover.hovered
                    QQC2.ToolTip.text: i18n("Abrir teclado numérico")
                    QQC2.ToolTip.delay: 450
                }
                Text { text: i18n("Teclado"); font.pixelSize: 11; color: CachyPalette.text; Layout.alignment: Qt.AlignHCenter }
            }

            // 3. Altavoz
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: phoneController.isSpeakerOn
                        ? "#FFFFFF"
                        : (spkTap.pressed ? CachyPalette.pressedOverlay : (spkHover.hovered ? CachyPalette.cardBackgroundHover : (CachyPalette.isDark ? "#2C2C2E" : "#E5E5EA")))
                    border.width: 1
                    border.color: CachyPalette.specularBorder

                    scale: spkTap.pressed ? 0.94 : (spkHover.hovered ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutBack } }

                    CachyIcon {
                        name: "audio-speakers"
                        size: 26
                        color: phoneController.isSpeakerOn ? "black" : CachyPalette.text
                        anchors.centerIn: parent
                    }
                    HoverHandler { id: spkHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { id: spkTap; onTapped: phoneController.toggleSpeaker() }

                    QQC2.ToolTip.visible: spkHover.hovered
                    QQC2.ToolTip.text: phoneController.isSpeakerOn ? i18n("Desactivar altavoz") : i18n("Activar altavoz")
                    QQC2.ToolTip.delay: 450
                }
                Text { text: i18n("Altavoz"); font.pixelSize: 11; color: CachyPalette.text; Layout.alignment: Qt.AlignHCenter }
            }

            // 4. Phone Mirroring Shortcut
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: mirrorTap.pressed ? "#4745B8" : "#5856D6"
                    border.width: 1
                    border.color: CachyPalette.specularBorder

                    scale: mirrorTap.pressed ? 0.94 : (mirrorHover.hovered ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutBack } }

                    CachyIcon {
                        name: "smartphone"
                        size: 26
                        color: "white"
                        anchors.centerIn: parent
                    }
                    HoverHandler { id: mirrorHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        id: mirrorTap
                        onTapped: phoneController.openPhoneMirroring()
                    }

                    QQC2.ToolTip.visible: mirrorHover.hovered
                    QQC2.ToolTip.text: i18n("Duplicar pantalla del móvil")
                    QQC2.ToolTip.delay: 450
                }
                Text { text: i18n("Pantalla"); font.pixelSize: 11; color: CachyPalette.text; Layout.alignment: Qt.AlignHCenter }
            }

            // 5. Mensaje rápido
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: msgTap.pressed ? CachyPalette.pressedOverlay : (msgHover.hovered ? CachyPalette.cardBackgroundHover : (CachyPalette.isDark ? "#2C2C2E" : "#E5E5EA"))
                    border.width: 1
                    border.color: CachyPalette.specularBorder

                    scale: msgTap.pressed ? 0.94 : (msgHover.hovered ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutBack } }

                    CachyIcon {
                        name: "message-new"
                        size: 24
                        color: CachyPalette.text
                        anchors.centerIn: parent
                    }
                    HoverHandler { id: msgHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        id: msgTap
                        onTapped: phoneController.openSms(phoneController.dialedNumber)
                    }

                    QQC2.ToolTip.visible: msgHover.hovered
                    QQC2.ToolTip.text: i18n("Enviar mensaje SMS")
                    QQC2.ToolTip.delay: 450
                }
                Text { text: i18n("Mensaje"); font.pixelSize: 11; color: CachyPalette.text; Layout.alignment: Qt.AlignHCenter }
            }

            // 6. Contactos
            ColumnLayout {
                spacing: 4
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: contTap.pressed ? CachyPalette.pressedOverlay : (contHover.hovered ? CachyPalette.cardBackgroundHover : (CachyPalette.isDark ? "#2C2C2E" : "#E5E5EA"))
                    border.width: 1
                    border.color: CachyPalette.specularBorder

                    scale: contTap.pressed ? 0.94 : (contHover.hovered ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutBack } }

                    CachyIcon {
                        name: "contact-new"
                        size: 24
                        color: CachyPalette.text
                        anchors.centerIn: parent
                    }
                    HoverHandler { id: contHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        id: contTap
                        onTapped: mainTabBar.currentIndex = 2 // Switch to Contacts tab
                    }

                    QQC2.ToolTip.visible: contHover.hovered
                    QQC2.ToolTip.text: i18n("Ver lista de contactos")
                    QQC2.ToolTip.delay: 450
                }
                Text { text: i18n("Contactos"); font.pixelSize: 11; color: CachyPalette.text; Layout.alignment: Qt.AlignHCenter }
            }
        }

        Item { Layout.fillHeight: true }

        // End Call Button (Big Red Circle)
        Rectangle {
            id: endCallBtn
            width: 68
            height: 68
            radius: 34
            color: endTap.pressed ? "#D32F2F" : "#FF3B30"
            border.width: 1
            border.color: CachyPalette.specularBorder
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 16

            scale: endTap.pressed ? 0.94 : (endHover.hovered ? 1.05 : 1.0)
            Behavior on scale { NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutBack } }

            CachyIcon {
                name: "call-start"
                size: 32
                color: "#FFFFFF"
                rotation: 135
                anchors.centerIn: parent
            }

            HoverHandler { id: endHover; cursorShape: Qt.PointingHandCursor }
            TapHandler {
                id: endTap
                onTapped: phoneController.endCall()
            }

            QQC2.ToolTip.visible: endHover.hovered
            QQC2.ToolTip.text: i18n("Finalizar llamada")
            QQC2.ToolTip.delay: 450
        }
    }
}
