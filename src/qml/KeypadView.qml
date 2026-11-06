import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 19
    implicitHeight: mainCol.implicitHeight + Kirigami.Units.largeSpacing * 2

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
            spacing: Kirigami.Units.smallSpacing

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
                        color: Kirigami.Theme.highlightColor
                        visible: text.length > 0
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Dialed Number Display
                    Text {
                        text: phoneController.formattedNumber.length > 0 ? phoneController.formattedNumber : ""
                        font.pixelSize: phoneController.formattedNumber.length > 12 ? 22 : 30
                        font.weight: Font.Medium
                        color: Kirigami.Theme.textColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Keypad Grid 3x4
            GridLayout {
                id: keypadGrid
                columns: 3
                Layout.alignment: Qt.AlignHCenter
                columnSpacing: Math.max(16, Kirigami.Units.largeSpacing * 1.5)
                rowSpacing: Math.max(8, Kirigami.Units.smallSpacing * 1.5)

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
                            ? (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#48484A" : "#D1D1D6")
                            : (Kirigami.Theme.backgroundColor.hslLightness < 0.5 ? "#2C2C2E" : "#E5E5EA")

                        Behavior on color { ColorAnimation { duration: 100 } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0

                            Text {
                                text: modelData.num
                                font.pixelSize: modelData.num === "*" || modelData.num === "#" ? 28 : (root.buttonSize < 60 ? 22 : 26)
                                font.weight: Font.Normal
                                color: Kirigami.Theme.textColor
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: modelData.sub
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: Kirigami.Theme.disabledTextColor
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
                Layout.preferredHeight: root.buttonSize + Kirigami.Units.smallSpacing
                Layout.topMargin: Kirigami.Units.smallSpacing

                // Green Call Button (Centered)
                Rectangle {
                    id: callBtn
                    width: root.buttonSize
                    height: root.buttonSize
                    radius: root.buttonSize / 2
                    color: callMouse.pressed ? "#2DB84D" : "#34C759"
                    anchors.centerIn: parent

                    Behavior on color { ColorAnimation { duration: 100 } }

                    Kirigami.Icon {
                        source: "call-start"
                        width: root.buttonSize * 0.44
                        height: root.buttonSize * 0.44
                        color: "white"
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
                    anchors.leftMargin: Kirigami.Units.largeSpacing
                    anchors.verticalCenter: callBtn.verticalCenter
                    visible: phoneController.dialedNumber.length > 0

                    Kirigami.Icon {
                        source: "edit-clear-locationbar-rtl"
                        width: 22
                        height: 22
                        color: Kirigami.Theme.textColor
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
