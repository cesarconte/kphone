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

    implicitWidth: 380
    implicitHeight: 560

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: CachyTheme.marginWindow
        spacing: CachyTheme.spacingMedium

        // Top Navigation Header with Centered Segmented Control & Clear Action
        RowLayout {
            Layout.fillWidth: true
            spacing: CachyTheme.spacingSmall

            // Left: Clear history action button
            CachyButton {
                id: clearBtn
                text: recentsModel.onlyMissed ? i18n("Borrar perdidas") : i18n("Borrar")
                iconName: "edit-delete"
                pillStyle: true
                visible: (recentsModel.onlyMissed ? recentsModel.missedCount : recentsModel.allCount) > 0
                onClicked: clearConfirmDialog.open()
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: recentsModel.onlyMissed ? i18n("Limpiar llamadas perdidas") : i18n("Vaciar historial de llamadas")
                QQC2.ToolTip.delay: 450
            }

            // Expanding spacer before center
            Item {
                Layout.fillWidth: true
            }

            // Center Segmented Control (Todas | Perdidas)
            CachySegmentedControl {
                id: segCtrl
                Layout.alignment: Qt.AlignHCenter
                accentSelected: true
                model: [i18n("Todas"), recentsModel.missedCount > 0 ? i18n("Perdidas (%1)", recentsModel.missedCount) : i18n("Perdidas")]
                currentIndex: recentsModel.onlyMissed ? 1 : 0
                onCurrentIndexChanged: {
                    recentsModel.onlyMissed = (currentIndex === 1);
                }
            }

            Connections {
                target: recentsModel
                function onOnlyMissedChanged() {
                    segCtrl.currentIndex = recentsModel.onlyMissed ? 1 : 0;
                }
            }

            // Expanding spacer after center
            Item {
                Layout.fillWidth: true
            }

            // Right spacer to keep segmented bar strictly centered when clearBtn is visible
            Item {
                Layout.preferredWidth: clearBtn.visible ? clearBtn.width : 0
                Layout.preferredHeight: clearBtn.height
            }
        }

        // Recent Calls List
        ListView {
            id: recentsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: recentsModel
            spacing: CachyTheme.spacingSmall

            delegate: Rectangle {
                id: itemCard
                required property var model
                width: recentsList.width
                height: 60
                radius: CachyTheme.radiusMedium

                // Surface styling
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
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    // 1. Leading: Directional badge
                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        radius: 19
                        color: itemCard.model.type === 2
                            ? (CachyPalette.isDark ? "#361616" : "#FEECEC")
                            : (itemCard.model.type === 0
                                ? (CachyPalette.isDark ? "#182635" : "#EAF2FC")
                                : (CachyPalette.isDark ? "#1A3820" : "#EAF7EE"))

                        CachyIcon {
                            anchors.centerIn: parent
                            name: itemCard.model.type === 2
                                ? "call-missed"
                                : (itemCard.model.type === 0 ? "call-outgoing" : "call-incoming")
                            size: 18
                            color: itemCard.model.type === 2
                                ? "#FF3B30"
                                : (itemCard.model.type === 0 ? "#007AFF" : "#34C759")
                        }
                    }

                    // 2. Center: Contact name, formatted number & call type
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Text {
                            text: itemCard.model.name
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: itemCard.model.type === 2 ? "#FF3B30" : CachyPalette.text
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: 6
                            Text {
                                text: itemCard.model.formattedNumber
                                font.pixelSize: 12
                                color: CachyPalette.textSecondary
                                elide: Text.ElideRight
                            }
                            Text {
                                text: "•"
                                font.pixelSize: 10
                                color: CachyPalette.textSecondary
                            }
                            Text {
                                text: itemCard.model.type === 2
                                    ? i18n("Perdida")
                                    : (itemCard.model.type === 0 ? i18n("Saliente") : i18n("Entrante"))
                                font.pixelSize: 12
                                color: itemCard.model.type === 2 ? "#FF3B30" : CachyPalette.textSecondary
                            }
                        }
                    }

                    // 3. Trailing: Timestamp & Duration
                    ColumnLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 2

                        Text {
                            text: itemCard.model.formattedDate
                            font.pixelSize: 12
                            color: CachyPalette.textSecondary
                            Layout.alignment: Qt.AlignRight
                        }

                        Text {
                            text: itemCard.model.duration
                            font.pixelSize: 11
                            color: CachyPalette.textSecondary
                            visible: itemCard.model.type !== 2 && text !== "00:00"
                            Layout.alignment: Qt.AlignRight
                        }
                    }

                    // 4. Delete single call button
                    Rectangle {
                        id: delBtn
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 16
                        color: delTap.pressed
                            ? (CachyPalette.isDark ? "#401A1A" : "#FDD8D8")
                            : (delHover.hovered
                                ? (CachyPalette.isDark ? "#2C1B1B" : "#FEECEC")
                                : "transparent")

                        opacity: itemHover.hovered || delHover.hovered ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 100 } }

                        CachyIcon {
                            anchors.centerIn: parent
                            name: "edit-delete"
                            size: 16
                            color: delHover.hovered ? "#FF3B30" : CachyPalette.textSecondary
                        }

                        HoverHandler {
                            id: delHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            id: delTap
                            onTapped: recentsModel.removeById(itemCard.model.callId)
                        }

                        QQC2.ToolTip.visible: delHover.hovered
                        QQC2.ToolTip.text: i18n("Eliminar del historial")
                        QQC2.ToolTip.delay: 450
                    }
                }

                HoverHandler {
                    id: itemHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    id: itemTap
                    onTapped: phoneController.startCall(itemCard.model.number)
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: rowContextMenu.popup()
                }

                CachyMenu {
                    id: rowContextMenu

                    CachyMenuItem {
                        text: i18n("Llamar a %1", itemCard.model.name)
                        iconName: "call-start"
                        onTriggered: phoneController.startCall(itemCard.model.number)
                    }

                    CachyMenuItem {
                        text: i18n("Copiar número")
                        iconName: "edit-copy"
                        onTriggered: phoneController.copyToClipboard(itemCard.model.number)
                    }

                    CachyMenuSeparator {}

                    CachyMenuItem {
                        text: i18n("Eliminar de recientes")
                        iconName: "edit-delete"
                        destructive: true
                        onTriggered: recentsModel.removeById(itemCard.model.callId)
                    }
                }
            }
        }
    }

    CachyPlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - 48
        visible: recentsModel.count === 0
        iconName: recentsModel.onlyMissed ? "call-missed" : "chronometer"
        text: recentsModel.onlyMissed ? i18n("Sin llamadas perdidas\nNo tienes llamadas perdidas registradas") : i18n("Sin llamadas recientes\nLas llamadas entrantes, salientes y perdidas aparecerán aquí")
    }

    // Modal Confirmation Dialog for clearing calls
    CachyDialog {
        id: clearConfirmDialog
        title: recentsModel.onlyMissed ? i18n("Borrar llamadas perdidas") : i18n("Borrar llamadas recientes")
        subtitle: recentsModel.onlyMissed
            ? i18n("¿Estás seguro de que deseas eliminar todas las llamadas perdidas (%1)?", recentsModel.missedCount)
            : i18n("¿Estás seguro de que deseas vaciar el historial de llamadas recientes (%1)?", recentsModel.allCount)
        preferredWidth: 360
        showCancelButton: true
        cancelText: i18n("Cancelar")

        ColumnLayout {
            Layout.fillWidth: true
            spacing: CachyTheme.spacingSmall

            CachyButton {
                Layout.fillWidth: true
                text: recentsModel.onlyMissed ? i18n("Borrar perdidas") : i18n("Borrar todas")
                iconName: "edit-delete"
                pillStyle: true
                primary: true
                onClicked: {
                    if (recentsModel.onlyMissed) {
                        recentsModel.clearMissed();
                    } else {
                        recentsModel.clearHistory();
                    }
                    clearConfirmDialog.close();
                }
            }

            CachyButton {
                Layout.fillWidth: true
                text: i18n("Solo llamadas perdidas (%1)", recentsModel.missedCount)
                iconName: "call-missed"
                pillStyle: true
                visible: !recentsModel.onlyMissed && recentsModel.missedCount > 0
                onClicked: {
                    recentsModel.clearMissed();
                    clearConfirmDialog.close();
                }
            }
        }
    }
}
