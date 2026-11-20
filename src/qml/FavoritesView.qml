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
            color: CachyTheme.textPrimary
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
                width: favList.width
                height: 64
                radius: CachyTheme.radiusMedium

                // Surface color following macOS Golden Gate
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

                    // 1. Leading: Circular Avatar
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
                            color: CachyTheme.textPrimary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.formattedNumber
                            font.pixelSize: 13
                            color: CachyTheme.textSecondary
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

                // Whole-card click to call
                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    z: -1
                    onClicked: phoneController.startCall(model.number)
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
