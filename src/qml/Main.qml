import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: appWindow
    title: i18n("Teléfono")
    width: 370
    height: 620
    minimumWidth: 320
    minimumHeight: 540

    // Top Device Status Bar
    header: QQC2.ToolBar {
        background: Rectangle {
            color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1C1C1E" : "#F8F8F8"
            border.color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA"
            border.width: 1
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            // Status Indicator Dot
            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                radius: 4
                color: phoneController.isDeviceConnected ? "#34C759" : "#FF9500"
            }

            // Device Name
            Text {
                text: phoneController.connectedDeviceName
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: Kirigami.Theme.textColor
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // Battery %
            RowLayout {
                spacing: 4
                visible: phoneController.deviceBattery >= 0

                Text {
                    text: phoneController.deviceBattery + "%"
                    font.pixelSize: 11
                    color: Kirigami.Theme.disabledTextColor
                }

                Kirigami.Icon {
                    source: "battery"
                    Layout.preferredWidth: 14
                    Layout.preferredHeight: 14
                    color: Kirigami.Theme.disabledTextColor
                }
            }

            // Quick Mirroring Action Icon
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 6
                color: mirrorMouse.pressed ? "#48484A" : "transparent"

                Kirigami.Icon {
                    source: "kphonemirroring"
                    width: 16
                    height: 16
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: mirrorMouse
                    anchors.fill: parent
                    onClicked: phoneController.openPhoneMirroring()
                }
            }
        }
    }

    // Main Tab Views
    StackLayout {
        id: viewStack
        anchors.fill: parent
        currentIndex: mainTabBar.currentIndex

        FavoritesView {}
        RecentsView {}
        ContactsView {}
        KeypadView {}
    }

    // In-Call Screen Overlay
    InCallView {
        anchors.fill: parent
        visible: phoneController.callState !== 0
        z: 99
    }

    // Bottom macOS Phone Tab Bar
    footer: QQC2.TabBar {
        id: mainTabBar
        currentIndex: 3 // Default to Keypad
        visible: phoneController.callState === 0

        background: Rectangle {
            color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1C1C1E" : "#F8F8F8"
            border.color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA"
            border.width: 1
        }

        QQC2.TabButton {
            contentItem: ColumnLayout {
                spacing: 2
                Kirigami.Icon {
                    source: "starred-symbolic"
                    width: 20
                    height: 20
                    color: mainTabBar.currentIndex === 0 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: i18n("Favoritos")
                    font.pixelSize: 10
                    font.weight: mainTabBar.currentIndex === 0 ? Font.DemiBold : Font.Normal
                    color: mainTabBar.currentIndex === 0 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        QQC2.TabButton {
            contentItem: ColumnLayout {
                spacing: 2
                Kirigami.Icon {
                    source: "clock"
                    width: 20
                    height: 20
                    color: mainTabBar.currentIndex === 1 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: i18n("Recientes")
                    font.pixelSize: 10
                    font.weight: mainTabBar.currentIndex === 1 ? Font.DemiBold : Font.Normal
                    color: mainTabBar.currentIndex === 1 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        QQC2.TabButton {
            contentItem: ColumnLayout {
                spacing: 2
                Kirigami.Icon {
                    source: "user-identity"
                    width: 20
                    height: 20
                    color: mainTabBar.currentIndex === 2 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: i18n("Contactos")
                    font.pixelSize: 10
                    font.weight: mainTabBar.currentIndex === 2 ? Font.DemiBold : Font.Normal
                    color: mainTabBar.currentIndex === 2 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        QQC2.TabButton {
            contentItem: ColumnLayout {
                spacing: 2
                Kirigami.Icon {
                    source: "input-dialpad"
                    width: 20
                    height: 20
                    color: mainTabBar.currentIndex === 3 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: i18n("Teclado")
                    font.pixelSize: 10
                    font.weight: mainTabBar.currentIndex === 3 ? Font.DemiBold : Font.Normal
                    color: mainTabBar.currentIndex === 3 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
