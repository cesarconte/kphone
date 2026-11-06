import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var selectedContact: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Search Bar
        Kirigami.SearchField {
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
            spacing: 6

            delegate: Rectangle {
                id: contactCard
                width: contactsList.width
                height: 64
                radius: 12

                color: itemMouse.pressed 
                    ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA")
                    : (itemMouse.containsMouse 
                        ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#28282A" : "#F2F2F5") 
                        : (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1C1C1E" : "#FFFFFF"))

                border.color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA"
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
                            color: Kirigami.Theme.textColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.formattedNumber.length > 0 ? model.formattedNumber : model.email
                            font.pixelSize: 13
                            color: Kirigami.Theme.disabledTextColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Star if favorite
                    Kirigami.Icon {
                        source: "starred-symbolic"
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
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
                                ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#224A2A" : "#DDF3E4")
                                : (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1A3820" : "#EAF7EE"))

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Kirigami.Icon {
                            source: "call-start"
                            width: 20
                            height: 20
                            color: callMouse.pressed ? "#FFFFFF" : "#34C759"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: callMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: phoneController.startCall(model.number)
                        }
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
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

    // Contact Details Modal Dialog
    Kirigami.Dialog {
        id: contactDialog
        title: ""
        width: Math.min(parent.width - 32, 340)
        padding: 16
        showCloseButton: true

        ColumnLayout {
            spacing: 16
            width: parent.width

            // Large Avatar
            Rectangle {
                width: 72
                height: 72
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
                color: Kirigami.Theme.textColor
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
                        width: 44
                        height: 44
                        radius: 22
                        color: "#34C759"
                        Kirigami.Icon {
                            source: "call-start"
                            width: 22
                            height: 22
                            color: "white"
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                contactDialog.close();
                                phoneController.startCall(root.selectedContact.number);
                            }
                        }
                    }
                    Text { text: i18n("Llamar"); font.pixelSize: 11; color: Kirigami.Theme.textColor; Layout.alignment: Qt.AlignHCenter }
                }

                // Mensaje (SMS)
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        color: "#007AFF"
                        Kirigami.Icon {
                            source: "message-new"
                            width: 20
                            height: 20
                            color: "white"
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                phoneController.openSms(root.selectedContact.number);
                            }
                        }
                    }
                    Text { text: i18n("Mensaje"); font.pixelSize: 11; color: Kirigami.Theme.textColor; Layout.alignment: Qt.AlignHCenter }
                }

                // Duplicación (Mirroring)
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        color: "#5856D6"
                        Kirigami.Icon {
                            source: "kphonemirroring"
                            width: 22
                            height: 22
                            color: "white"
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                phoneController.openPhoneMirroring();
                            }
                        }
                    }
                    Text { text: i18n("Pantalla"); font.pixelSize: 11; color: Kirigami.Theme.textColor; Layout.alignment: Qt.AlignHCenter }
                }

                // Favorito
                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        color: root.selectedContact && root.selectedContact.isFavorite ? "#FF9500" : (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#3A3A3C" : "#E5E5EA")
                        Kirigami.Icon {
                            source: "starred-symbolic"
                            width: 20
                            height: 20
                            color: root.selectedContact && root.selectedContact.isFavorite ? "white" : Kirigami.Theme.textColor
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (root.selectedContact) {
                                    contactsModel.toggleFavorite(root.selectedContact.id);
                                    root.selectedContact.isFavorite = !root.selectedContact.isFavorite;
                                }
                            }
                        }
                    }
                    Text { text: i18n("Favorito"); font.pixelSize: 11; color: Kirigami.Theme.textColor; Layout.alignment: Qt.AlignHCenter }
                }
            }

            // Info Box
            Rectangle {
                Layout.fillWidth: true
                height: 70
                radius: 10
                color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#F2F2F7"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Text {
                        text: i18n("Teléfono móvil")
                        font.pixelSize: 11
                        color: Kirigami.Theme.disabledTextColor
                    }

                    Text {
                        text: root.selectedContact ? root.selectedContact.formattedNumber : ""
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: Kirigami.Theme.highlightColor
                    }
                }
            }
        }
    }
}
