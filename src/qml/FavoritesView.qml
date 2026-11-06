import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Text {
            text: i18n("Favoritos")
            font.pixelSize: 22
            font.weight: Font.Bold
            color: Kirigami.Theme.textColor
            Layout.leftMargin: 4
            Layout.topMargin: 4
        }

        ListView {
            id: favList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: contactsModel
            spacing: 6

            delegate: Rectangle {
                width: favList.width
                height: 58
                radius: 10
                visible: model.isFavorite
                // Don't take space if not favorite
                Component.onCompleted: {
                    if (!model.isFavorite) {
                        height = 0;
                        visible = false;
                    }
                }

                color: favMouse.pressed 
                    ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA")
                    : (favMouse.containsMouse ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1C1C1E" : "#F2F2F7") : "transparent")

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 12

                    Rectangle {
                        width: 42
                        height: 42
                        radius: 21
                        color: model.avatarColor

                        Text {
                            anchors.centerIn: parent
                            text: model.initials
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: "white"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: model.name
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: Kirigami.Theme.textColor
                        }
                        Text {
                            text: model.formattedNumber
                            font.pixelSize: 12
                            color: Kirigami.Theme.disabledTextColor
                        }
                    }

                    Kirigami.Icon {
                        source: "call-start"
                        width: 20
                        height: 20
                        color: "#34C759"
                    }
                }

                MouseArea {
                    id: favMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: phoneController.startCall(model.number)
                }
            }
        }
    }
}
