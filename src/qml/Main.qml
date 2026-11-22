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

CachyWindow {
    id: appWindow
    title: i18n("Teléfono")
    width: 396
    height: 640
    minimumWidth: 350
    minimumHeight: 520

    showTrafficLights: true
    showTitle: false
    showTitleBarDivider: false
    showWindowFrame: true
    resizable: true
    cornerRadius: CachyTheme.radiusWindow

    // =========================================================================
    // HEADER ACTIONS — Golden Gate Action Capsule Group
    // =========================================================================
    headerActions: [
        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            CachyToolbarGroup {
                // 1. Device Connection Status Pill & Quick Details Popover
                Rectangle {
                    id: deviceStatusPill
                    height: 22
                    implicitWidth: Math.min(170, deviceStatusRow.implicitWidth + 16)
                    radius: 11
                    color: devicePillHover.hovered
                        ? CachyPalette.cardBackgroundHover
                        : (devicePillTap.pressed ? CachyPalette.pressedOverlay : "transparent")

                    Behavior on color { ColorAnimation { duration: CachyTheme.animFast } }

                    RowLayout {
                        id: deviceStatusRow
                        anchors.centerIn: parent
                        spacing: 5

                        // Status indicator dot
                        Rectangle {
                            Layout.preferredWidth: 7
                            Layout.preferredHeight: 7
                            radius: 3.5
                            color: phoneController.isDeviceConnected ? "#34C759" : "#FF9500"
                        }

                        Text {
                            text: phoneController.isDeviceConnected ? phoneController.connectedDeviceName : i18n("Sin conectar")
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: CachyPalette.text
                            elide: Text.ElideRight
                            Layout.maximumWidth: 100
                        }

                        Text {
                            visible: phoneController.isDeviceConnected && phoneController.deviceBattery >= 0
                            text: phoneController.deviceBattery + "%"
                            font.pixelSize: 10
                            color: CachyPalette.textSecondary
                        }
                    }

                    HoverHandler {
                        id: devicePillHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        id: devicePillTap
                        onTapped: devicePopover.openAt(deviceStatusPill)
                    }

                    QQC2.ToolTip.visible: devicePillHover.hovered
                    QQC2.ToolTip.text: phoneController.isDeviceConnected
                        ? (phoneController.deviceBattery >= 0
                            ? i18n("%1 (%2%)", phoneController.connectedDeviceName, phoneController.deviceBattery)
                            : phoneController.connectedDeviceName)
                        : i18n("Sin dispositivo conectado")
                    QQC2.ToolTip.delay: 450
                }

                // 2. Trailing Quick Phone Mirroring Button (Launches kphonemirroring)
                CachyToolbarButton {
                    iconName: "smartphone"
                    pillStyle: false
                    tooltipText: i18n("Duplicación de pantalla (kphonemirroring)")
                    onClicked: phoneController.openPhoneMirroring()
                }
            }
        }
    ]

    // =========================================================================
    // OVERLAYS (Device Status Popover)
    // =========================================================================
    overlay: [
        CachyPopover {
            id: devicePopover
            preferredWidth: 260
            preferredEdge: Qt.BottomEdge

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 16
                        color: phoneController.isDeviceConnected
                            ? CachyTheme.withAlpha("#34C759", 0.20)
                            : CachyTheme.withAlpha("#FF9500", 0.20)

                        CachyIcon {
                            anchors.centerIn: parent
                            name: "smartphone"
                            size: 16
                            color: phoneController.isDeviceConnected ? "#34C759" : "#FF9500"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: phoneController.isDeviceConnected ? phoneController.connectedDeviceName : i18n("Sin dispositivo")
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: CachyPalette.text
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: phoneController.isDeviceConnected ? i18n("KDE Connect • Conectado") : i18n("Esperando conexión")
                            font.pixelSize: 11
                            color: CachyPalette.textSecondary
                        }
                    }
                }

                // Battery Status Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: CachyTheme.radiusSmall
                    color: CachyPalette.cardBackground
                    border.width: 1
                    border.color: CachyPalette.specularBorder
                    visible: phoneController.isDeviceConnected && phoneController.deviceBattery >= 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        CachyIcon {
                            name: "battery"
                            size: 14
                            color: CachyPalette.textSecondary
                        }

                        Text {
                            Layout.fillWidth: true
                            text: i18n("Nivel de batería")
                            font.pixelSize: 11
                            color: CachyPalette.text
                        }

                        Text {
                            text: phoneController.deviceBattery + "%"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: phoneController.deviceBattery < 20 ? "#FF3B30" : CachyPalette.text
                        }
                    }
                }

                // Quick Action Button
                CachyButton {
                    Layout.fillWidth: true
                    text: i18n("Abrir duplicación de pantalla")
                    iconName: "smartphone"
                    pillStyle: true
                    primary: true
                    onClicked: {
                        devicePopover.close();
                        phoneController.openPhoneMirroring();
                    }
                }
            }
        }
    ]

    // =========================================================================
    // CONTENT DATA
    // =========================================================================
    contentData: [
        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Main Content Stack + InCall Overlay
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                StackLayout {
                    id: viewStack
                    anchors.fill: parent
                    currentIndex: mainTabBar.currentIndex

                    FavoritesView {}
                    RecentsView {}
                    ContactsView {}
                    KeypadView {}
                }

                InCallView {
                    anchors.fill: parent
                    visible: phoneController.callState !== 0
                    z: 99
                }
            }

            // Bottom Golden Gate Capsule Phone Tab Bar
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                visible: phoneController.callState === 0

                Rectangle {
                    id: mainTabBar
                    property int currentIndex: 3 // Default to Keypad
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: 16
                    color: CachyPalette.surfacePill
                    border.width: 1
                    border.color: CachyPalette.specularBorder

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 4

                        Repeater {
                            model: [
                                { index: 0, label: i18n("Favoritos"), icon: "starred-symbolic" },
                                { index: 1, label: i18n("Recientes"), icon: "clock" },
                                { index: 2, label: i18n("Contactos"), icon: "user-identity" },
                                { index: 3, label: i18n("Teclado"), icon: "input-dialpad" }
                            ]

                            Rectangle {
                                id: tabItemRect
                                required property var modelData
                                readonly property bool isCurrent: mainTabBar.currentIndex === modelData.index

                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                radius: 12
                                color: isCurrent
                                    ? CachyTheme.withAlpha(CachyTheme.accentColor, CachyPalette.isDark ? 0.22 : 0.14)
                                    : (tabHover.hovered ? CachyPalette.cardBackgroundHover : "transparent")

                                Behavior on color { ColorAnimation { duration: CachyTheme.animFast } }

                                HoverHandler { id: tabHover; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: mainTabBar.currentIndex = tabItemRect.modelData.index }

                                QQC2.ToolTip.visible: tabHover.hovered
                                QQC2.ToolTip.text: tabItemRect.modelData.label
                                QQC2.ToolTip.delay: 450

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    CachyIcon {
                                        name: tabItemRect.modelData.icon
                                        size: 16
                                        color: tabItemRect.isCurrent ? CachyTheme.accentColor : CachyPalette.textSecondary
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Text {
                                        text: tabItemRect.modelData.label
                                        font.pixelSize: 10
                                        font.weight: tabItemRect.isCurrent ? Font.Bold : Font.Medium
                                        color: tabItemRect.isCurrent ? CachyTheme.accentColor : CachyPalette.textSecondary
                                        elide: Text.ElideRight
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    ]
}
