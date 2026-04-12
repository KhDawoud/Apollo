import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: loginPage
    color: "transparent"
    Rectangle {
        id: loginRoot
        anchors.fill: parent
        color: "transparent"
        Rectangle {
            id: loginBox

            width: 450
            height: 550
            anchors.verticalCenter:  parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter


            color: Qt.rgba(17/255, 45/255, 78/255, 0.5)
            radius: 20
            border.color: "#4CC9FE"
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 25

                Text {
                    text: "WELCOME BACK"
                    color: "white"
                    font.bold: true
                    font.pointSize: 18
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10
                }

                // Username Input
                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Text { text: "USERNAME"; color: "#DBE2EF"; font.pointSize: 10; font.bold: true }

                    TextField {
                        id: userField
                        placeholderText: "Enter your username"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        leftPadding: 15
                        color: "white"
                        font.pointSize: 12

                        background: Rectangle {
                            color: "transparent"
                            radius: 10
                            border.color: userField.activeFocus ? "#4CC9FE" : "#DBE2EF"
                            border.width: 1
                        }
                    }
                }

                // Password Input
                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Text { text: "PASSWORD"; color: "#DBE2EF"; font.pointSize: 10; font.bold: true }

                    TextField {
                        id: passField
                        placeholderText: "Enter your password"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        leftPadding: 15
                        color: "white"
                        font.pointSize: 12

                        background: Rectangle {
                            color: "transparent"
                            radius: 10
                            border.color: passField.activeFocus ? "#4CC9FE" : "#DBE2EF"
                            border.width: 1
                        }
                    }
                }

                // Login Button
                Button {
                    id: loginBtn
                    text: "LOGIN"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    Layout.topMargin: 15

                    contentItem: Text {
                        text: loginBtn.text
                        font.bold: true
                        font.pointSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: loginBtn.down ? "#c23a13" : (loginBtn.hovered ? "#f05629" : "#E25822")
                        radius: 10

                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    onClicked: {
                        //here we will add the verification procces but for now it just logs you in
                        isLoggedIn = true
                        mainNavBar.currentIndex = 0 // Redirect to Home
                    }
                }

                Text {
                    text: "Forgot Password?"
                    color: "#DBE2EF"
                    font.pointSize: 10
                    Layout.alignment: Qt.AlignHCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: console.log("Reset password clicked")
                    }
                }
            }
        }
    }
}
