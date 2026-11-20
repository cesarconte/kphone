import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    implicitWidth: 380
    implicitHeight: 560

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: CachyTheme.marginWindow
        spacing: CachyTheme.spacingMedium

        // Top Navigation Header with Centered Segmented Control & Clear Action
        RowLayout {
            Layout.fillWidth: true
            spacing: CachyTheme.spacingSmall

            // Left: Clear history action button
            CachyButton {
                id: clearBtn
                text: recentsModel.onlyMissed ? i18n("Borrar perdidas") : i18n("Borrar")
                iconName: "edit-delete"
                visible: (recentsModel.onlyMissed ? recentsModel.missedCount : recentsModel.allCount) > 0
                onClicked: clearConfirmDialog.open()
            }

            // Expanding spacer before center
            Item {
                Layout.fillWidth: true
            }

            // Center Segmented Control (Todas | Perdidas)
            CachySegmentedControl {
                id: segCtrl
                Layout.alignment: Qt.AlignHCenter
                model: [i18n("Todas"), recentsModel.missedCount > 0 ? i18n("Perdidas (%1)", recentsModel.missedCount) : i18n("Perdidas")]
                currentIndex: recentsModel.onlyMissed ? 1 : 0
                onCurrentIndexChanged: {
                    recentsModel.onlyMissed = (currentIndex === 1);
                }
            }

            Connections {
                target: recentsModel
                function onOnlyMissedChanged() {
                    segCtrl.currentIndex = recentsModel.onlyMissed ? 1 : 0;
                }
            }

            // Expanding spacer after center
            Item {
                Layout.fillWidth: true
            }

            // Right spacer to keep segmented bar strictly centered when clearBtn is visible
            Item {
                Layout.preferredWidth: clearBtn.visible ? clearBtn.width : 0
                Layout.preferredHeight: clearBtn.height
            }
        }

        // Recent Calls List
        ListView {
            id: recentsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: recentsModel
            spacing: CachyTheme.spacingSmall

            delegate: Rectangle {
                id: itemCard
                width: recentsList.width
                height: 60
                radius: CachyTheme.radiusMedium

                // Surface styling
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
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    // 1. Leading: Directional badge
                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        radius: 19
                        color: model.type === 2 
                            ? (CachyTheme.isDark ? "#361616" : "#FEECEC")
                            : (model.type === 0 
                                ? (CachyTheme.isDark ? "#182635" : "#EAF2FC")
                                : (CachyTheme.isDark ? "#1A3820" : "#EAF7EE"))

                        CachyIcon {
                            anchors.centerIn: parent
                            name: model.type === 2 
                                ? "call-missed" 
                                : (model.type === 0 ? "call-outgoing" : "call-incoming")
                            size: 18
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
                            color: model.type === 2 ? "#FF3B30" : CachyTheme.textPrimary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: 6
                            Text {
                                text: model.formattedNumber
                                font.pixelSize: 12
                                color: CachyTheme.textSecondary
                                elide: Text.ElideRight
                            }
                            Text {
                                text: "•"
                                font.pixelSize: 10
                                color: CachyTheme.textSecondary
                            }
                            Text {
                                text: model.type === 2 
                                    ? i18n("Perdida") 
                                    : (model.type === 0 ? i18n("Saliente") : i18n("Entrante"))
                                font.pixelSize: 12
                                color: model.type === 2 ? "#FF3B30" : CachyTheme.textSecondary
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
                            color: CachyTheme.textSecondary
                            Layout.alignment: Qt.AlignRight
                        }

                        Text {
                            text: model.duration
                            font.pixelSize: 11
                            color: CachyTheme.textSecondary
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
                            ? (CachyTheme.isDark ? "#401A1A" : "#FDD8D8")
                            : (delMouse.containsMouse 
                                ? (CachyTheme.isDark ? "#2C1B1B" : "#FEECEC")
                                : "transparent")

                        opacity: itemMouse.containsMouse || delMouse.containsMouse ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 100 } }

                        CachyIcon {
                            anchors.centerIn: parent
                            name: "edit-delete"
                            size: 16
                            color: delMouse.containsMouse ? "#FF3B30" : CachyTheme.textSecondary
                        }

                        MouseArea {
                            id: delMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                mouse.accepted = true;
                                recentsModel.removeById(model.callId);
                            }
                        }
                    }
                }

                // Row click handler & context menu
                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    z: -1

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            rowContextMenu.popup();
                        } else {
                            phoneController.startCall(model.number);
                        }
                    }

                    CachyMenu {
                        id: rowContextMenu

                        CachyMenuItem {
                            text: i18n("Llamar a %1", model.name)
                            iconName: "call-start"
                            onTriggered: phoneController.startCall(model.number)
                        }

                        CachyMenuItem {
                            text: i18n("Copiar número")
                            iconName: "edit-copy"
                            onTriggered: phoneController.copyToClipboard(model.number)
                        }

                        CachyMenuSeparator {}

                        CachyMenuItem {
                            text: i18n("Eliminar de recientes")
                            iconName: "edit-delete"
                            destructive: true
                            onTriggered: recentsModel.removeById(model.callId)
                        }
                    }
                }
            }
        }
    }

    CachyPlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - 48
        visible: recentsModel.count === 0
        iconName: recentsModel.onlyMissed ? "call-missed" : "chronometer"
        text: recentsModel.onlyMissed ? i18n("Sin llamadas perdidas\nNo tienes llamadas perdidas registradas") : i18n("Sin llamadas recientes\nLas llamadas entrantes, salientes y perdidas aparecerán aquí")
    }

    // Modal Confirmation Dialog for clearing calls
    CachyDialog {
        id: clearConfirmDialog
        title: recentsModel.onlyMissed ? i18n("Borrar llamadas perdidas") : i18n("Borrar llamadas recientes")
        subtitle: recentsModel.onlyMissed
            ? i18n("¿Estás seguro de que deseas eliminar todas las llamadas perdidas (%1)?", recentsModel.missedCount)
            : i18n("¿Estás seguro de que deseas vaciar el historial de llamadas recientes (%1)?", recentsModel.allCount)
        preferredWidth: 360
        showCancelButton: true
        cancelText: i18n("Cancelar")

        ColumnLayout {
            Layout.fillWidth: true
            spacing: CachyTheme.spacingSmall

            CachyButton {
                Layout.fillWidth: true
                text: recentsModel.onlyMissed ? i18n("Borrar perdidas") : i18n("Borrar todas")
                iconName: "edit-delete"
                primary: true
                onClicked: {
                    if (recentsModel.onlyMissed) {
                        recentsModel.clearMissed();
                    } else {
                        recentsModel.clearHistory();
                    }
                    clearConfirmDialog.close();
                }
            }

            CachyButton {
                Layout.fillWidth: true
                text: i18n("Solo llamadas perdidas (%1)", recentsModel.missedCount)
                iconName: "call-missed"
                visible: !recentsModel.onlyMissed && recentsModel.missedCount > 0
                onClicked: {
                    recentsModel.clearMissed();
                    clearConfirmDialog.close();
                }
            }
        }
    }
}
