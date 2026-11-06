import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        // Section Title
        Text {
            text: i18n("Favoritos")
            font.pixelSize: 22
            font.weight: Font.Bold
            color: Kirigami.Theme.textColor
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
            spacing: 8

            delegate: Rectangle {
                id: itemCard
                width: favList.width
                height: 64
                radius: 12

                // Surface color following MD3 & KDE HIG
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

                    // 1. Leading: Circular Avatar (MD3 44dp spec)
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

                    // 2. Center: Contact Info (Name + Formatted Number)
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
                            text: model.formattedNumber
                            font.pixelSize: 13
                            color: Kirigami.Theme.disabledTextColor
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

                        // Soft green container (MD3 tonal style)
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
                            color: callMouse.pressed 
                                ? "#FFFFFF" 
                                : "#34C759"
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

                // Whole-card click to call
                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    z: -1
                    onClicked: phoneController.startCall(model.number)
                }
            }
        }
    }

    // Official KDE HIG Empty State Placeholder
    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.gridUnit * 4
        visible: favoritesModel.count === 0
        icon.name: "starred-symbolic"
        text: i18n("Sin contactos favoritos")
        explanation: i18n("Marca la estrella en la ficha de un contacto para añadirlo aquí")
    }
}
