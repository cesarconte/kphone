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

Item {
    id: root

    property var selectedContact: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: CachyTheme.marginWindow
        spacing: CachyTheme.spacingMedium

        // Search Bar (Golden Gate Capsule)
        CachySearchField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: i18n("Buscar contactos...")
            onTextChanged: contactsModel.filter = text
        }

        // Contacts List
        ListView {
            id: contactsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: contactsModel
            spacing: CachyTheme.spacingSmall

            delegate: Rectangle {
                id: contactCard
                required property var model
                width: contactsList.width
                height: 64
                radius: CachyTheme.radiusMedium

                color: itemTap.pressed
                    ? CachyPalette.pressedOverlay
                    : (itemHover.hovered
                        ? CachyPalette.cardBackgroundHover
                        : CachyPalette.cardBackground)

                border.color: CachyPalette.specularBorder
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 14

                    // 1. Avatar (44x44)
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: contactCard.model.avatarColor

                        Text {
                            anchors.centerIn: parent
                            text: contactCard.model.initials
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }
                    }

                    // 2. Contact Info
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Text {
                            text: contactCard.model.name
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: CachyPalette.text
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: contactCard.model.formattedNumber.length > 0 ? contactCard.model.formattedNumber : contactCard.model.email
                            font.pixelSize: 13
                            color: CachyPalette.textSecondary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Star if favorite
                    CachyIcon {
                        name: "starred-symbolic"
                        size: 16
                        color: "#FF9500"
                        visible: contactCard.model.isFavorite
                    }

                    // 3. Quick call button (40x40 tonal container)
                    Rectangle {
                        id: quickCallBtn
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: callTap.pressed
                            ? "#2DB84D"
                            : (callHover.hovered
                                ? (CachyPalette.isDark ? "#224A2A" : "#DDF3E4")
                                : (CachyPalette.isDark ? "#1A3820" : "#EAF7EE"))

                        Behavior on color { ColorAnimation { duration: 120 } }

                        scale: callTap.pressed ? 0.94 : (callHover.hovered ? 1.05 : 1.0)
                        Behavior on scale {
                            NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutBack }
                        }

                        CachyIcon {
                            name: "call-start"
                            size: 20
                            color: callTap.pressed ? "#FFFFFF" : "#34C759"
                            anchors.centerIn: parent
                        }

                        HoverHandler {
                            id: callHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            id: callTap
                            onTapped: phoneController.startCall(contactCard.model.number)
                        }

                        QQC2.ToolTip.visible: callHover.hovered
                        QQC2.ToolTip.text: i18n("Llamar")
                        QQC2.ToolTip.delay: 450
                    }
                }

                HoverHandler {
                    id: itemHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: itemTap
                    onTapped: {
                        root.selectedContact = {
                            id: contactCard.model.id,
                            name: contactCard.model.name,
                            number: contactCard.model.number,
                            formattedNumber: contactCard.model.formattedNumber,
                            email: contactCard.model.email,
                            initials: contactCard.model.initials,
                            avatarColor: contactCard.model.avatarColor,
                            isFavorite: contactCard.model.isFavorite
                        };
                        contactDialog.open();
                    }
                }
            }
        }
    }

    CachyPlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - 48
        visible: contactsModel.count === 0
        iconName: "user-identity"
        text: searchField.text.length > 0 ? i18n("No se encontraron contactos para \"%1\"", searchField.text) : i18n("Sin contactos")
    }

    // Contact Details Modal Dialog (macOS Golden Gate styled)
    CachyDialog {
        id: contactDialog
        title: ""
        preferredWidth: 340
        showCancelButton: true
        cancelText: i18n("Cerrar")

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            // Large Avatar
            Rectangle {
                Layout.preferredWidth: 72
                Layout.preferredHeight: 72
                radius: 36
                color: root.selectedContact ? root.selectedContact.avatarColor : "#007AFF"
                Layout.alignment: Qt.AlignHCenter

                Text {
                    anchors.centerIn: parent
                    text: root.selectedContact ? root.selectedContact.initials : "?"
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    color: "white"
                }
            }

            // Name
            Text {
                text: root.selectedContact ? root.selectedContact.name : ""
                font.pixelSize: 18
                font.weight: Font.Bold
                color: CachyPalette.text
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            // Action Quick Buttons Row (macOS Golden Gate circular action cluster)
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                // Llamar
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: callBtnTap.pressed ? "#2DB84D" : "#34C759"
                        border.width: 1
                        border.color: CachyPalette.specularBorder

                        CachyIcon {
                            name: "call-start"
                            size: 22
                            color: "white"
                            anchors.centerIn: parent
                        }
                        HoverHandler { id: callBtnHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            id: callBtnTap
                            onTapped: {
                                contactDialog.close();
                                phoneController.startCall(root.selectedContact.number);
                            }
                        }
                        QQC2.ToolTip.visible: callBtnHover.hovered
                        QQC2.ToolTip.text: i18n("Iniciar llamada")
                        QQC2.ToolTip.delay: 450
                    }
                    Text { text: i18n("Llamar"); font.pixelSize: 11; color: CachyPalette.text; Layout.alignment: Qt.AlignHCenter }
                }

                // Mensaje (SMS)
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: msgBtnTap.pressed ? "#0062CC" : "#007AFF"
                        border.width: 1
                        border.color: CachyPalette.specularBorder

                        CachyIcon {
                            name: "message-new"
                            size: 20
                            color: "white"
                            anchors.centerIn: parent
                        }
                        HoverHandler { id: msgBtnHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            id: msgBtnTap
                            onTapped: {
                                phoneController.openSms(root.selectedContact.number);
                            }
                        }
                        QQC2.ToolTip.visible: msgBtnHover.hovered
                        QQC2.ToolTip.text: i18n("Enviar mensaje")
                        QQC2.ToolTip.delay: 450
                    }
                    Text { text: i18n("Mensaje"); font.pixelSize: 11; color: CachyPalette.text; Layout.alignment: Qt.AlignHCenter }
                }

                // Duplicación (Mirroring)
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: mirrorBtnTap.pressed ? "#4745B8" : "#5856D6"
                        border.width: 1
                        border.color: CachyPalette.specularBorder

                        CachyIcon {
                            name: "smartphone"
                            size: 22
                            color: "white"
                            anchors.centerIn: parent
                        }
                        HoverHandler { id: mirrorBtnHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            id: mirrorBtnTap
                            onTapped: {
                                phoneController.openPhoneMirroring();
                            }
                        }
                        QQC2.ToolTip.visible: mirrorBtnHover.hovered
                        QQC2.ToolTip.text: i18n("Duplicar pantalla")
                        QQC2.ToolTip.delay: 450
                    }
                    Text { text: i18n("Pantalla"); font.pixelSize: 11; color: CachyPalette.text; Layout.alignment: Qt.AlignHCenter }
                }

                // Favorito
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: root.selectedContact && root.selectedContact.isFavorite ? "#FF9500" : (CachyPalette.isDark ? "#3A3A3C" : "#E5E5EA")
                        border.width: 1
                        border.color: CachyPalette.specularBorder

                        CachyIcon {
                            name: "starred-symbolic"
                            size: 20
                            color: root.selectedContact && root.selectedContact.isFavorite ? "white" : CachyPalette.text
                            anchors.centerIn: parent
                        }
                        HoverHandler { id: favBtnHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            id: favBtnTap
                            onTapped: {
                                if (root.selectedContact) {
                                    contactsModel.toggleFavorite(root.selectedContact.id);
                                    root.selectedContact.isFavorite = !root.selectedContact.isFavorite;
                                }
                            }
                        }
                        QQC2.ToolTip.visible: favBtnHover.hovered
                        QQC2.ToolTip.text: root.selectedContact && root.selectedContact.isFavorite ? i18n("Quitar de favoritos") : i18n("Añadir a favoritos")
                        QQC2.ToolTip.delay: 450
                    }
                    Text { text: i18n("Favorito"); font.pixelSize: 11; color: CachyPalette.text; Layout.alignment: Qt.AlignHCenter }
                }
            }

            // Info Box
            Rectangle {
                Layout.fillWidth: true
                height: 70
                radius: CachyTheme.radiusMedium
                color: CachyPalette.cardBackground
                border.width: 1
                border.color: CachyPalette.specularBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Text {
                        text: i18n("Teléfono móvil")
                        font.pixelSize: 11
                        color: CachyPalette.textSecondary
                    }

                    Text {
                        text: root.selectedContact ? root.selectedContact.formattedNumber : ""
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: CachyTheme.accentColor
                    }
                }
            }
        }
    }
}
