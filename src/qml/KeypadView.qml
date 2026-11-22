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

    implicitWidth: 340
    implicitHeight: mainCol.implicitHeight + CachyTheme.spacingLarge * 2

    // Responsive button dimension adapting to window height
    readonly property real buttonSize: Math.max(54, Math.min(68, Math.floor((root.height - 200) / 4.6)))

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: Math.max(height, mainCol.implicitHeight)
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: mainCol
            width: parent.width
            anchors.centerIn: parent
            spacing: CachyTheme.spacingSmall

            // Top display area
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(64, root.height * 0.14)

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    // Contact name if recognized
                    Text {
                        text: phoneController.activeContactName
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: CachyTheme.accentColor
                        visible: text.length > 0
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Dialed Number Display
                    Text {
                        text: phoneController.formattedNumber.length > 0 ? phoneController.formattedNumber : ""
                        font.pixelSize: phoneController.formattedNumber.length > 12 ? 22 : 30
                        font.weight: Font.Medium
                        color: CachyPalette.text
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Keypad Grid 3x4
            GridLayout {
                id: keypadGrid
                columns: 3
                Layout.alignment: Qt.AlignHCenter
                columnSpacing: Math.max(16, CachyTheme.spacingLarge * 1.5)
                rowSpacing: Math.max(8, CachyTheme.spacingSmall * 1.5)

                Repeater {
                    model: [
                        { num: "1", sub: "" },
                        { num: "2", sub: "A B C" },
                        { num: "3", sub: "D E F" },
                        { num: "4", sub: "G H I" },
                        { num: "5", sub: "J K L" },
                        { num: "6", sub: "M N O" },
                        { num: "7", sub: "P Q R S" },
                        { num: "8", sub: "T U V" },
                        { num: "9", sub: "W X Y Z" },
                        { num: "*", sub: "" },
                        { num: "0", sub: "+" },
                        { num: "#", sub: "" }
                    ]

                    delegate: Rectangle {
                        id: btnRect
                        required property var modelData
                        width: root.buttonSize
                        height: root.buttonSize
                        radius: root.buttonSize / 2
                        color: btnTap.pressed
                            ? (CachyPalette.isDark ? "#48484A" : "#D1D1D6")
                            : (btnHover.hovered
                                ? (CachyPalette.isDark ? "#3A3A3C" : "#DCDCE0")
                                : (CachyPalette.isDark ? "#2C2C2E" : "#E5E5EA"))
                        border.width: 1
                        border.color: CachyPalette.specularBorder

                        Behavior on color { ColorAnimation { duration: 100 } }

                        scale: btnTap.pressed ? 0.94 : (btnHover.hovered ? 1.04 : 1.0)
                        Behavior on scale {
                            NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutBack }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0

                            Text {
                                text: btnRect.modelData.num
                                font.pixelSize: btnRect.modelData.num === "*" || btnRect.modelData.num === "#" ? 28 : (root.buttonSize < 60 ? 22 : 26)
                                font.weight: Font.Normal
                                color: CachyPalette.text
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: btnRect.modelData.sub
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: CachyPalette.textSecondary
                                visible: btnRect.modelData.sub.length > 0 && root.buttonSize >= 56
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        HoverHandler {
                            id: btnHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            id: btnTap
                            onTapped: {
                                phoneController.appendDigit(btnRect.modelData.num);
                            }
                            onLongPressed: {
                                if (btnRect.modelData.num === "0") {
                                    phoneController.deleteDigit();
                                    phoneController.appendDigit("+");
                                }
                            }
                        }
                    }
                }
            }

            // Bottom Actions: Call & Backspace
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.buttonSize + CachyTheme.spacingSmall
                Layout.topMargin: CachyTheme.spacingSmall

                // Green Call Button (Centered)
                Rectangle {
                    id: callBtn
                    width: root.buttonSize
                    height: root.buttonSize
                    radius: root.buttonSize / 2
                    color: callTap.pressed ? "#2DB84D" : "#34C759"
                    border.width: 1
                    border.color: CachyPalette.specularBorder
                    anchors.centerIn: parent

                    Behavior on color { ColorAnimation { duration: 100 } }

                    scale: callTap.pressed ? 0.94 : (callHover.hovered ? 1.04 : 1.0)
                    Behavior on scale {
                        NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutBack }
                    }

                    CachyIcon {
                        name: "call-start"
                        size: Math.round(root.buttonSize * 0.44)
                        color: "#FFFFFF"
                        anchors.centerIn: parent
                    }

                    HoverHandler {
                        id: callHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        id: callTap
                        onTapped: phoneController.startCall()
                    }

                    QQC2.ToolTip.visible: callHover.hovered
                    QQC2.ToolTip.text: i18n("Llamar")
                    QQC2.ToolTip.delay: 450
                }

                // Backspace Button (Right aligned)
                Rectangle {
                    id: backspaceBtn
                    width: root.buttonSize * 0.65
                    height: root.buttonSize * 0.65
                    radius: width / 2
                    color: backTap.pressed
                        ? CachyPalette.pressedOverlay
                        : (backHover.hovered ? CachyPalette.cardBackgroundHover : "transparent")
                    anchors.left: callBtn.right
                    anchors.leftMargin: CachyTheme.spacingLarge
                    anchors.verticalCenter: callBtn.verticalCenter
                    visible: phoneController.dialedNumber.length > 0

                    Behavior on color { ColorAnimation { duration: 100 } }

                    CachyIcon {
                        name: "edit-clear-locationbar-rtl"
                        size: 20
                        color: CachyPalette.text
                        anchors.centerIn: parent
                    }

                    HoverHandler {
                        id: backHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        id: backTap
                        onTapped: phoneController.deleteDigit()
                        onLongPressed: phoneController.clearNumber()
                    }

                    QQC2.ToolTip.visible: backHover.hovered
                    QQC2.ToolTip.text: i18n("Borrar")
                    QQC2.ToolTip.delay: 450
                }
            }
        }
    }
}
