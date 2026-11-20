import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    implicitWidth: 340
    implicitHeight: mainCol.implicitHeight + CachyTheme.spacingLarge * 2

    // Responsive button dimension adapting to window height
    readonly property real buttonSize: Math.max(54, Math.min(68, Math.floor((root.height - 200) / 4.6)))

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: Math.max(height, mainCol.implicitHeight)
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: mainCol
            width: parent.width
            anchors.centerIn: parent
            spacing: CachyTheme.spacingSmall

            // Top display area
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(64, root.height * 0.14)

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    // Contact name if recognized
                    Text {
                        text: phoneController.activeContactName
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: CachyTheme.accentColor
                        visible: text.length > 0
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Dialed Number Display
                    Text {
                        text: phoneController.formattedNumber.length > 0 ? phoneController.formattedNumber : ""
                        font.pixelSize: phoneController.formattedNumber.length > 12 ? 22 : 30
                        font.weight: Font.Medium
                        color: CachyTheme.textPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Keypad Grid 3x4
            GridLayout {
                id: keypadGrid
                columns: 3
                Layout.alignment: Qt.AlignHCenter
                columnSpacing: Math.max(16, CachyTheme.spacingLarge * 1.5)
                rowSpacing: Math.max(8, CachyTheme.spacingSmall * 1.5)

                Repeater {
                    model: [
                        { num: "1", sub: "" },
                        { num: "2", sub: "A B C" },
                        { num: "3", sub: "D E F" },
                        { num: "4", sub: "G H I" },
                        { num: "5", sub: "J K L" },
                        { num: "6", sub: "M N O" },
                        { num: "7", sub: "P Q R S" },
                        { num: "8", sub: "T U V" },
                        { num: "9", sub: "W X Y Z" },
                        { num: "*", sub: "" },
                        { num: "0", sub: "+" },
                        { num: "#", sub: "" }
                    ]

                    delegate: Rectangle {
                        id: btnRect
                        width: root.buttonSize
                        height: root.buttonSize
                        radius: root.buttonSize / 2
                        color: mouseArea.pressed 
                            ? (CachyTheme.isDark ? "#48484A" : "#D1D1D6")
                            : (CachyTheme.isDark ? "#2C2C2E" : "#E5E5EA")

                        Behavior on color { ColorAnimation { duration: 100 } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0

                            Text {
                                text: modelData.num
                                font.pixelSize: modelData.num === "*" || modelData.num === "#" ? 28 : (root.buttonSize < 60 ? 22 : 26)
                                font.weight: Font.Normal
                                color: CachyTheme.textPrimary
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: modelData.sub
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: CachyTheme.textSecondary
                                visible: modelData.sub.length > 0 && root.buttonSize >= 56
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: {
                                phoneController.appendDigit(modelData.num);
                            }
                            onPressAndHold: {
                                if (modelData.num === "0") {
                                    phoneController.deleteDigit();
                                    phoneController.appendDigit("+");
                                }
                            }
                        }
                    }
                }
            }

            // Bottom Actions: Call & Backspace
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.buttonSize + CachyTheme.spacingSmall
                Layout.topMargin: CachyTheme.spacingSmall

                // Green Call Button (Centered)
                Rectangle {
                    id: callBtn
                    width: root.buttonSize
                    height: root.buttonSize
                    radius: root.buttonSize / 2
                    color: callMouse.pressed ? "#2DB84D" : "#34C759"
                    anchors.centerIn: parent

                    Behavior on color { ColorAnimation { duration: 100 } }

                    CachyIcon {
                        name: "call-start"
                        size: Math.round(root.buttonSize * 0.44)
                        color: "#FFFFFF"
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: callMouse
                        anchors.fill: parent
                        onClicked: {
                            phoneController.startCall();
                        }
                    }
                }

                // Backspace Button (Right aligned)
                Rectangle {
                    width: root.buttonSize * 0.65
                    height: root.buttonSize * 0.65
                    radius: width / 2
                    color: "transparent"
                    anchors.left: callBtn.right
                    anchors.leftMargin: CachyTheme.spacingLarge
                    anchors.verticalCenter: callBtn.verticalCenter
                    visible: phoneController.dialedNumber.length > 0

                    CachyIcon {
                        name: "edit-clear-locationbar-rtl"
                        size: 22
                        color: CachyTheme.textPrimary
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: phoneController.deleteDigit()
                        onPressAndHold: phoneController.clearNumber()
                    }
                }
            }
        }
    }
}
