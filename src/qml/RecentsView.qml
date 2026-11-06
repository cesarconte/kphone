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

        // Top Segmented Bar: Todas vs Perdidas
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            Rectangle {
                width: 110
                height: 32
                radius: 8
                color: !recentsModel.onlyMissed 
                    ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#636366" : "#FFFFFF")
                    : (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1C1C1E" : "#E5E5EA")

                Text {
                    anchors.centerIn: parent
                    text: i18n("Todas")
                    font.pixelSize: 13
                    font.weight: !recentsModel.onlyMissed ? Font.Bold : Font.Normal
                    color: Kirigami.Theme.textColor
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: recentsModel.onlyMissed = false
                }
            }

            Rectangle {
                width: 110
                height: 32
                radius: 8
                color: recentsModel.onlyMissed 
                    ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#636366" : "#FFFFFF")
                    : (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1C1C1E" : "#E5E5EA")

                Text {
                    anchors.centerIn: parent
                    text: i18n("Perdidas")
                    font.pixelSize: 13
                    font.weight: recentsModel.onlyMissed ? Font.Bold : Font.Normal
                    color: recentsModel.onlyMissed ? "#FF3B30" : Kirigami.Theme.textColor
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: recentsModel.onlyMissed = true
                }
            }
        }

        // List
        ListView {
            id: recentsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: recentsModel
            spacing: 4

            delegate: Rectangle {
                width: recentsList.width
                height: 52
                radius: 10
                color: rowMouse.pressed 
                    ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA")
                    : (rowMouse.containsMouse ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1C1C1E" : "#F2F2F7") : "transparent")

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 12

                    // Call Type Icon
                    Kirigami.Icon {
                        source: model.type === 2 ? "call-missed" : (model.type === 0 ? "call-outgoing" : "call-incoming")
                        width: 18
                        height: 18
                        color: model.type === 2 ? "#FF3B30" : Kirigami.Theme.disabledTextColor
                    }

                    // Name / Number
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: model.name
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: model.type === 2 ? "#FF3B30" : Kirigami.Theme.textColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.number
                            font.pixelSize: 12
                            color: Kirigami.Theme.disabledTextColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Date & Duration
                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: model.formattedDate
                            font.pixelSize: 12
                            color: Kirigami.Theme.disabledTextColor
                            Layout.alignment: Qt.AlignRight
                        }
                        Text {
                            text: model.duration
                            font.pixelSize: 10
                            color: Kirigami.Theme.disabledTextColor
                            visible: model.type !== 2 && text !== "00:00"
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: phoneController.startCall(model.number)
                }
            }

            // Empty state placeholder
            Item {
                anchors.centerIn: parent
                visible: recentsModel.count === 0
                ColumnLayout {
                    spacing: 8
                    Kirigami.Icon {
                        source: "call-missed"
                        width: 48
                        height: 48
                        color: Kirigami.Theme.disabledTextColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: i18n("Sin llamadas recientes")
                        color: Kirigami.Theme.disabledTextColor
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
