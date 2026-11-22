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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: CachyTheme.marginWindow
        spacing: CachyTheme.spacingMedium

        // Section Title
        Text {
            text: i18n("Favoritos")
            font.pixelSize: 22
            font.weight: Font.Bold
            color: CachyPalette.text
            Layout.leftMargin: 4
            Layout.topMargin: 2
        }

        // Favorites List
        ListView {
            id: favList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: favoritesModel
            spacing: CachyTheme.spacingSmall

            delegate: Rectangle {
                id: itemCard
                required property var model
                width: favList.width
                height: 64
                radius: CachyTheme.radiusMedium

                // Surface color following macOS Golden Gate
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

                    // 1. Leading: Circular Avatar
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: itemCard.model.avatarColor

                        Text {
                            anchors.centerIn: parent
                            text: itemCard.model.initials
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }
                    }

                    // 2. Center: Contact Info (Name + Formatted Number)
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Text {
                            text: itemCard.model.name
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: CachyPalette.text
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: itemCard.model.formattedNumber
                            font.pixelSize: 13
                            color: CachyPalette.textSecondary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // 3. Trailing: Interactive Circular Call Button
                    Rectangle {
                        id: callBtn
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20

                        // Soft green container
                        color: callTap.pressed
                            ? "#2DB84D"
                            : (callHover.hovered
                                ? (CachyPalette.isDark ? "#224A2A" : "#DDF3E4")
                                : (CachyPalette.isDark ? "#1A3820" : "#EAF7EE"))

                        border.width: 1
                        border.color: CachyPalette.specularBorder

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
                            onTapped: phoneController.startCall(itemCard.model.number)
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

                // Whole-card click to call
                TapHandler {
                    id: itemTap
                    onTapped: phoneController.startCall(itemCard.model.number)
                }
            }
        }
    }

    CachyPlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - 48
        visible: favoritesModel.count === 0
        iconName: "starred-symbolic"
        text: i18n("Sin contactos favoritos\nMarca la estrella en la ficha de un contacto para añadirlo aquí")
    }
}
