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

        // Search Bar
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
                width: contactsList.width
                height: 64
                radius: CachyTheme.radiusMedium

                color: itemMouse.pressed 
                    ? (CachyTheme.isDark ? "#2C2C2E" : "#E5E5EA")
                    : (itemMouse.containsMouse 
                        ? (CachyTheme.isDark ? "#28282A" : "#F2F2F5") 
                        : (CachyTheme.isDark ? "#1C1C1E" : "#FFFFFF"))

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
                        color: model.avatarColor

                        Text {
                            anchors.centerIn: parent
                            text: model.initials
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
                            text: model.name
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: CachyTheme.textPrimary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.formattedNumber.length > 0 ? model.formattedNumber : model.email
                            font.pixelSize: 13
                            color: CachyTheme.textSecondary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Star if favorite
                    CachyIcon {
                        name: "starred-symbolic"
                        size: 16
                        color: "#FF9500"
                        visible: model.isFavorite
                    }

                    // 3. Quick call button (40x40 tonal container)
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: callMouse.pressed
                            ? "#2DB84D"
                            : (callMouse.containsMouse
                                ? (CachyTheme.isDark ? "#224A2A" : "#DDF3E4")
                                : (CachyTheme.isDark ? "#1A3820" : "#EAF7EE"))

                        Behavior on color { ColorAnimation { duration: 120 } }

                        CachyIcon {
                            name: "call-start"
                            size: 20
                            color: callMouse.pressed ? "#FFFFFF" : "#34C759"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: callMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: phoneController.startCall(model.number)
                        }
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selectedContact = {
                            id: model.id,
                            name: model.name,
                            number: model.number,
                            formattedNumber: model.formattedNumber,
                            email: model.email,
                            initials: model.initials,
                            avatarColor: model.avatarColor,
                            isFavorite: model.isFavorite
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

    // Contact Details Modal Dialog
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
                color: CachyTheme.textPrimary
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            // Action Quick Buttons Row
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
                        color: "#34C759"
                        CachyIcon {
                            name: "call-start"
                            size: 22
                            color: "white"
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                contactDialog.close();
                                phoneController.startCall(root.selectedContact.number);
                            }
                        }
                    }
                    Text { text: i18n("Llamar"); font.pixelSize: 11; color: CachyTheme.textPrimary; Layout.alignment: Qt.AlignHCenter }
                }

                // Mensaje (SMS)
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: "#007AFF"
                        CachyIcon {
                            name: "message-new"
                            size: 20
                            color: "white"
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                phoneController.openSms(root.selectedContact.number);
                            }
                        }
                    }
                    Text { text: i18n("Mensaje"); font.pixelSize: 11; color: CachyTheme.textPrimary; Layout.alignment: Qt.AlignHCenter }
                }

                // Duplicación (Mirroring)
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: "#5856D6"
                        CachyIcon {
                            name: "smartphone"
                            size: 22
                            color: "white"
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                phoneController.openPhoneMirroring();
                            }
                        }
                    }
                    Text { text: i18n("Pantalla"); font.pixelSize: 11; color: CachyTheme.textPrimary; Layout.alignment: Qt.AlignHCenter }
                }

                // Favorito
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: root.selectedContact && root.selectedContact.isFavorite ? "#FF9500" : (CachyTheme.isDark ? "#3A3A3C" : "#E5E5EA")
                        CachyIcon {
                            name: "starred-symbolic"
                            size: 20
                            color: root.selectedContact && root.selectedContact.isFavorite ? "white" : CachyTheme.textPrimary
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.selectedContact) {
                                    contactsModel.toggleFavorite(root.selectedContact.id);
                                    root.selectedContact.isFavorite = !root.selectedContact.isFavorite;
                                }
                            }
                        }
                    }
                    Text { text: i18n("Favorito"); font.pixelSize: 11; color: CachyTheme.textPrimary; Layout.alignment: Qt.AlignHCenter }
                }
            }

            // Info Box
            Rectangle {
                Layout.fillWidth: true
                height: 70
                radius: CachyTheme.radiusMedium
                color: CachyTheme.isDark ? "#2C2C2E" : "#F2F2F7"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Text {
                        text: i18n("Teléfono móvil")
                        font.pixelSize: 11
                        color: CachyTheme.textSecondary
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
