//Login
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

        Connections {
            target: authManager

            function onLoginSuccess(totalXp) {
                console.log("Logged in! User XP: " + totalXp);
                loginBtn.enabled = true;
                loginBtn.text = "LOGIN";

                isLoggedIn = true;
                mainNavBar.currentIndex = 0; // sends you home after logging you in
            }

            function onLoginFailed(errorMessage) {
                console.log("Login Failed: " + errorMessage);
                loginBtn.enabled = true;
                loginBtn.text = "LOGIN";

                // need to show this error next
            }
        }
        //back button to be able to traverse back to home as the tabbar is not shown
        Button {
            text: "← Back to Home"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 20
            
            onClicked: mainNavBar.currentIndex = 0 // Back to Home

            background: Rectangle { color: "transparent" }
            contentItem: Text {
                text: parent.text
                color: "#4CC9FE"
                font.pointSize: 12
            }
        }

        Text {
            id: loginTitle
            text: "SIGN IN"
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.05
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
            font.pointSize: 40
            color: "white"
        }

        Rectangle {
            id: loginBox
            width: 450
            height: 550
            anchors.top: loginTitle.bottom
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            color: Qt.rgba(17 / 255, 45 / 255, 78 / 255, 0.5) // makes the box have 50% opacity
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
                    Text {
                        text: "USERNAME OR EMAIL"
                        color: "#DBE2EF"
                        font.pointSize: 10
                        font.bold: true
                    }

                    TextField {
                        id: userField
                        placeholderText: "Enter your username or email"
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
                    Text {
                        text: "PASSWORD"
                        color: "#DBE2EF"
                        font.pointSize: 10
                        font.bold: true
                    }

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
                        color: loginBtn.down ? "#c23a13" : (loginBtn.hovered ? "#f05629" : "#444444")
                        radius: 10

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }
                    }

                    onClicked: {
                        loginBtn.enabled = false;
                        loginBtn.text = "LOGGING IN...";
                        authManager.login(userField.text, passField.text);
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    // Footer link that allows you to signup
                    Text {
                        text: "Create an account"
                        color: "#DBE2EF"
                        font.pointSize: 10

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                console.log("Navigating to Sign Up page...");
                                mainNavBar.currentIndex = 5;
                            }
                        }
                    }
                    // seperator betweem the two texts
                    Rectangle {
                        width: 1
                        height: 12
                        color: "#3F72AF"
                        opacity: 0.5
                    }
                    // doesn't do anything for now  
                    Text {
                        text: "Forgot Password?"
                        color: "#DBE2EF"
                        font.pointSize: 10

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
}
