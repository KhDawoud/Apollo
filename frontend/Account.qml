import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: parent.width
    height: parent.height
    function openAccount() { accountWindow.open() }
    function openSettings() { settingsWindow.open() }

    Popup {
        id: accountWindow
        anchors.centerIn: Overlay.overlay
        width: Math.min(parent.width * 0.8, 450)
        height: Math.min(parent.height * 0.7, 400)

        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1B3B5F" }
                GradientStop { position: 1.0; color: "#112D4E" }
            }
            radius: 15
            border.color: "#3F72AF"
            border.width: 2
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            //level badge area
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                Layout.bottomMargin: 10

                // Level Circle
                Rectangle {
                    width: 60; height: 60; radius: 30
                    color: "#0F203D"
                    border.color: "#4CC9FE"; border.width: 2

                    Column {
                        anchors.centerIn: parent
                        Text { text: "LVL"; color: "#3F72AF"; font.pointSize: 8; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "24"; color: "white"; font.pointSize: 16; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "MY PROFILE"
                        color: "white"
                        font.bold: true
                        font.pointSize: 14
                        font.letterSpacing: 1
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#3F72AF"
                opacity: 0.4
            }

            GridLayout {
                columns: 2
                rowSpacing: 12
                columnSpacing: 20
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.alignment: Qt.AlignHCenter

                Text { text: "USERNAME:"; color: "#3F72AF"; font.bold: true; font.pointSize: 10 }
                Text { text: username; color: "white"; font.pointSize: 11; font.family: "Monospace" }

                Text { text: "STREAK:"; color: "#3F72AF"; font.bold: true; font.pointSize: 10 }
                Text { text: userstreak + " WINS"; color: "#ff4d4d"; font.pointSize: 11; font.bold: true }
            }

            Item { Layout.fillHeight: true }

            Button {
                text: "CLOSE"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                onClicked: accountWindow.close()

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.hovered ? "#3F72AF" : "#2E5A8E"
                    radius: 8
                }
            }
        }
    }

    Popup {
        id: settingsWindow
        anchors.centerIn: Overlay.overlay
        width: Math.min(parent.width * 0.8, 450)
        height: Math.min(parent.height * 0.7, 400)
        modal: true
        focus: true

        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1B3B5F" }
                GradientStop { position: 1.0; color: "#112D4E" }
            }
            radius: 15
            border.color: "#3F72AF"
            border.width: 2
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Text {
                text: "SETTINGS"
                color: "white"
                font.bold: true
                font.pointSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 20

                // Fullscreen Toggle Row
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "FULLSCREEN MODE"
                        color: "#DBE2EF"
                        font.pointSize: 11
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: screencontrol
                        checked: window.visibility === Window.FullScreen

                        onCheckedChanged: {
                            if (checked) {
                                window.visibility = Window.FullScreen
                            } else {
                                window.visibility = Window.Maximized
                            }
                        }
                        indicator: Rectangle {
                            implicitWidth: 48
                            implicitHeight: 26
                            x: screencontrol.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 13
                            color: screencontrol.checked ? "#3F72AF" : "#0F203D"
                            border.color: screencontrol.checked ? "#4CC9FE" : "#3F72AF"
                            border.width: 2

                            // The Sliding Circle (Handle)
                            Rectangle {
                                x: screencontrol.checked ? parent.width - width - 4 : 4
                                anchors.verticalCenter: parent.verticalCenter
                                width: 18
                                height: 18
                                radius: 9
                                color: screencontrol.checked ? "#ffffff" : "#DBE2EF"
                                // Smooth slide animation
                                Behavior on x {
                                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                }
                            }
                        }
                    }
                }

                // Volume Row
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "MASTER VOLUME"; color: "#DBE2EF"; font.pointSize: 11; Layout.fillWidth: true }
                    Slider {
                        id: volumeSlider
                        from: 0
                        to: 100
                        value: 80
                        Layout.preferredWidth: 150

                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 6
                            width: volumeSlider.availableWidth
                            height: implicitHeight
                            radius: 3
                            color: "#0F203D"

                            Rectangle {
                                width: volumeSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#3F72AF"
                                radius: 3
                            }
                        }

                        handle: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 10
                            color: volumeSlider.pressed ? "#DBE2EF" : "#3F72AF"
                            border.color: "#ffffff"
                            border.width: 1
                            layer.enabled: true
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Button {
                text: "CLOSE"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 160
                Layout.preferredHeight: 40
                onClicked: settingsWindow.close()

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.hovered ? "#3F72AF" : "#2E5A8E"
                    radius: 8
                }
            }
        }
    }
}
