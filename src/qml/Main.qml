import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import CachyOS.UI

CachyWindow {
    id: appWindow
    title: i18n("Teléfono")
    width: 396
    height: 640
    minimumWidth: 350
    minimumHeight: 540

    showTrafficLights: true
    showTitleBarDivider: true
    showWindowFrame: true
    resizable: true
    cornerRadius: CachyTheme.radiusWindow

    // Golden Gate Centered Device Connection & Battery Pill
    headerCenter: [
        Rectangle {
            anchors.centerIn: parent
            height: 26
            width: Math.min(parent.width, statusRow.implicitWidth + 20)
            radius: 13
            color: CachyTheme.surfacePill
            border.width: 1
            border.color: CachyTheme.specularBorder

            RowLayout {
                id: statusRow
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 6

                Rectangle {
                    Layout.preferredWidth: 8
                    Layout.preferredHeight: 8
                    radius: 4
                    color: phoneController.isDeviceConnected ? "#34C759" : "#FF9500"
                }

                Text {
                    text: phoneController.connectedDeviceName
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: CachyTheme.textPrimary
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    visible: phoneController.deviceBattery >= 0
                    text: phoneController.deviceBattery + "%"
                    font.pixelSize: 11
                    color: CachyTheme.textSecondary
                }
            }
        }
    ]

    // Trailing Quick Phone Mirroring Button (Launches kphonemirroring)
    headerActions: [
        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            CachyToolbarButton {
                text: "📱"
                tooltipText: i18n("Abrir iPhone / Android Mirroring (kphonemirroring)")
                onClicked: phoneController.openPhoneMirroring()
            }
        }
    ]

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

            // Golden Gate 1px Bottom Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                visible: phoneController.callState === 0
                color: CachyTheme.hardDividerColor
            }

            // Bottom Golden Gate Segmented Phone Tab Bar
            Rectangle {
                id: mainTabBar
                property int currentIndex: 3 // Default to Keypad
                Layout.fillWidth: true
                Layout.preferredHeight: 58
                visible: phoneController.callState === 0
                color: CachyTheme.sidebarBackground

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 6

                    Repeater {
                        model: [
                            { index: 0, label: i18n("Favoritos"), icon: "starred-symbolic" },
                            { index: 1, label: i18n("Recientes"), icon: "clock" },
                            { index: 2, label: i18n("Contactos"), icon: "user-identity" },
                            { index: 3, label: i18n("Teclado"), icon: "input-dialpad" }
                        ]

                        Rectangle {
                            required property var modelData
                            readonly property bool isCurrent: mainTabBar.currentIndex === modelData.index

                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            radius: 12
                            color: isCurrent
                                ? CachyTheme.withAlpha(CachyTheme.accentColor, CachyTheme.isDark ? 0.22 : 0.14)
                                : (tabHover.hovered ? CachyTheme.cardBackgroundHover : "transparent")

                            HoverHandler { id: tabHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: mainTabBar.currentIndex = modelData.index }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2

                                Kirigami.Icon {
                                    source: modelData.icon
                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18
                                    color: isCurrent ? CachyTheme.accentColor : CachyTheme.textSecondary
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: modelData.label
                                    font.pixelSize: 10
                                    font.weight: isCurrent ? Font.Bold : Font.Medium
                                    color: isCurrent ? CachyTheme.accentColor : CachyTheme.textSecondary
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    ]
}
