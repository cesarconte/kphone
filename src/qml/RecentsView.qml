import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Top Navigation Header with Centered Segmented Control & Clear Action
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 2
            Layout.rightMargin: 2
            spacing: 8

            // Left: Clear history action button
            QQC2.Button {
                id: clearBtn
                text: i18n("Borrar")
                icon.name: "edit-delete"
                flat: true
                Layout.preferredHeight: 32
                visible: (recentsModel.onlyMissed ? recentsModel.missedCount : recentsModel.allCount) > 0

                contentItem: RowLayout {
                    spacing: 4
                    Kirigami.Icon {
                        source: clearBtn.icon.name
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        color: clearBtn.down ? "#CC2D25" : "#FF3B30"
                    }
                    Text {
                        text: clearBtn.text
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: clearBtn.down ? "#CC2D25" : "#FF3B30"
                    }
                }

                background: Rectangle {
                    radius: 8
                    color: clearBtn.hovered 
                        ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C1B1B" : "#FEECEC") 
                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                onClicked: clearMenu.open()

                QQC2.Menu {
                    id: clearMenu
                    y: clearBtn.height + 4

                    QQC2.MenuItem {
                        text: recentsModel.onlyMissed 
                            ? i18n("Borrar llamadas perdidas (%1)", recentsModel.missedCount)
                            : i18n("Borrar todo el historial (%1)", recentsModel.allCount)
                        icon.name: "edit-delete"
                        onTriggered: recentsModel.clearCurrent()
                    }

                    QQC2.MenuItem {
                        text: i18n("Borrar solo llamadas perdidas (%1)", recentsModel.missedCount)
                        icon.name: "call-missed"
                        visible: !recentsModel.onlyMissed && recentsModel.missedCount > 0
                        onTriggered: recentsModel.clearMissed()
                    }

                    QQC2.MenuItem {
                        text: i18n("Borrar todas las llamadas (%1)", recentsModel.allCount)
                        icon.name: "edit-delete"
                        visible: recentsModel.onlyMissed && (recentsModel.allCount > recentsModel.missedCount)
                        onTriggered: recentsModel.clearHistory()
                    }
                }
            }

            // Expanding spacer before center
            Item {
                Layout.fillWidth: true
            }

            // Center Segmented Capsule (Todas | Perdidas)
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 200
                height: 32
                radius: 8
                color: Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1C1C1E" : "#E5E5EA"

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Option "Todas"
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: !recentsModel.onlyMissed 
                            ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#636366" : "#FFFFFF")
                            : "transparent"

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: i18n("Todas")
                            font.pixelSize: 13
                            font.weight: !recentsModel.onlyMissed ? Font.Bold : Font.Normal
                            color: Kirigami.Theme.textColor
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: recentsModel.onlyMissed = false
                        }
                    }

                    // Option "Perdidas"
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: recentsModel.onlyMissed 
                            ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#636366" : "#FFFFFF")
                            : "transparent"

                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                text: i18n("Perdidas")
                                font.pixelSize: 13
                                font.weight: recentsModel.onlyMissed ? Font.Bold : Font.Normal
                                color: recentsModel.onlyMissed ? "#FF3B30" : Kirigami.Theme.textColor
                            }
                            // Badge with count of missed calls if > 0
                            Rectangle {
                                visible: recentsModel.missedCount > 0
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                radius: 8
                                color: "#FF3B30"
                                Text {
                                    anchors.centerIn: parent
                                    text: recentsModel.missedCount > 99 ? "99+" : recentsModel.missedCount
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                    color: "#FFFFFF"
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: recentsModel.onlyMissed = true
                        }
                    }
                }
            }

            // Expanding spacer after center
            Item {
                Layout.fillWidth: true
            }

            // Right spacer to keep segmented bar strictly centered when clearBtn is visible
            Item {
                Layout.preferredWidth: clearBtn.visible ? clearBtn.width : 0
                Layout.preferredHeight: 32
            }
        }

        // Recent Calls List
        ListView {
            id: recentsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: recentsModel
            spacing: 8

            delegate: Rectangle {
                id: itemCard
                width: recentsList.width
                height: 60
                radius: 12

                // MD3 Surface styling
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
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    // 1. Leading: Directional badge
                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        radius: 19
                        color: model.type === 2 
                            ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#361616" : "#FEECEC")
                            : (model.type === 0 
                                ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#182635" : "#EAF2FC")
                                : (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#1A3820" : "#EAF7EE"))

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            source: model.type === 2 
                                ? "call-missed" 
                                : (model.type === 0 ? "call-outgoing" : "call-incoming")
                            width: 18
                            height: 18
                            color: model.type === 2 
                                ? "#FF3B30" 
                                : (model.type === 0 ? "#007AFF" : "#34C759")
                        }
                    }

                    // 2. Center: Contact name, formatted number & call type
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Text {
                            text: model.name
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: model.type === 2 ? "#FF3B30" : Kirigami.Theme.textColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: 6
                            Text {
                                text: model.formattedNumber
                                font.pixelSize: 12
                                color: Kirigami.Theme.disabledTextColor
                                elide: Text.ElideRight
                            }
                            Text {
                                text: "•"
                                font.pixelSize: 10
                                color: Kirigami.Theme.disabledTextColor
                            }
                            Text {
                                text: model.type === 2 
                                    ? i18n("Perdida") 
                                    : (model.type === 0 ? i18n("Saliente") : i18n("Entrante"))
                                font.pixelSize: 12
                                color: model.type === 2 ? "#FF3B30" : Kirigami.Theme.disabledTextColor
                            }
                        }
                    }

                    // 3. Trailing: Timestamp & Duration
                    ColumnLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 2

                        Text {
                            text: model.formattedDate
                            font.pixelSize: 12
                            color: Kirigami.Theme.disabledTextColor
                            Layout.alignment: Qt.AlignRight
                        }

                        Text {
                            text: model.duration
                            font.pixelSize: 11
                            color: Kirigami.Theme.disabledTextColor
                            visible: model.type !== 2 && text !== "00:00"
                            Layout.alignment: Qt.AlignRight
                        }
                    }

                    // 4. Delete single call button
                    Rectangle {
                        id: delBtn
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 16
                        color: delMouse.pressed 
                            ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#401A1A" : "#FDD8D8")
                            : (delMouse.containsMouse 
                                ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C1B1B" : "#FEECEC")
                                : "transparent")

                        opacity: itemMouse.containsMouse || delMouse.containsMouse ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            source: "edit-delete"
                            width: 16
                            height: 16
                            color: delMouse.containsMouse ? "#FF3B30" : Kirigami.Theme.disabledTextColor
                        }

                        MouseArea {
                            id: delMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: recentsModel.removeAt(index)
                        }

                        QQC2.ToolTip.visible: delMouse.containsMouse
                        QQC2.ToolTip.text: i18n("Eliminar esta llamada")
                        QQC2.ToolTip.delay: 400
                    }
                }

                // Row click handler & context menu
                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    z: -1

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            rowContextMenu.popup();
                        } else {
                            phoneController.startCall(model.number);
                        }
                    }

                    QQC2.Menu {
                        id: rowContextMenu

                        QQC2.MenuItem {
                            text: i18n("Llamar a %1", model.name)
                            icon.name: "call-start"
                            onTriggered: phoneController.startCall(model.number)
                        }

                        QQC2.MenuItem {
                            text: i18n("Copiar número")
                            icon.name: "edit-copy"
                            onTriggered: phoneController.copyToClipboard(model.number)
                        }

                        QQC2.MenuSeparator {}

                        QQC2.MenuItem {
                            text: i18n("Eliminar de recientes")
                            icon.name: "edit-delete"
                            onTriggered: recentsModel.removeAt(index)
                        }
                    }
                }
            }

            // Empty state placeholder
            Item {
                anchors.centerIn: parent
                visible: recentsModel.count === 0
                ColumnLayout {
                    spacing: 10
                    Kirigami.Icon {
                        source: recentsModel.onlyMissed ? "call-missed" : "chronometer"
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        color: Kirigami.Theme.disabledTextColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: recentsModel.onlyMissed 
                            ? i18n("Sin llamadas perdidas") 
                            : i18n("Sin llamadas recientes")
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: Kirigami.Theme.textColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: recentsModel.onlyMissed
                            ? i18n("No tienes llamadas perdidas registradas")
                            : i18n("Las llamadas entrantes, salientes y perdidas aparecerán aquí")
                        font.pixelSize: 12
                        color: Kirigami.Theme.disabledTextColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
