import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: signupPage
    anchors.fill: parent
    color: "transparent"
    anchors.bottomMargin: 50

    Connections {
        target: authManager

        function onSignupSuccess(totalXp) {
            console.log("Signup Success! User XP: " + totalXp);
            signupBtn.enabled = true;
            signupBtn.text = "SIGN UP";

            isLoggedIn = true;
            mainNavBar.currentIndex = 0;
        }

        function onSignupFailed(errorMessage) {
            console.log("Signup Failed: " + errorMessage);
            signupBtn.enabled = true;
            signupBtn.text = "SIGN UP";
            // we need to actually display these errors next
        }
    }
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
        id: signupTitle
        text: "SIGN UP"
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.05
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        font.pointSize: 40
        color: "white"
    }

    Rectangle {
        id: signupBox
        width: 450
        height: 600
        anchors.top: signupTitle.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        color: Qt.rgba(17 / 255, 45 / 255, 78 / 255, 0.5)
        radius: 20
        border.color: "#4CC9FE"
        border.width: 2

        ColumnLayout {
            id: signupColumn
            anchors.fill: parent
            anchors.margins: 40
            spacing: 12

            Text {
                text: "CREATE ACCOUNT"
                color: "white"
                font.bold: true
                font.pointSize: 18
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 5
            }

            // added email bardo
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true
                Text {
                    text: "EMAIL"
                    color: "#DBE2EF"
                    font.pointSize: 10
                    font.bold: true
                }
                TextField {
                    id: emailField
                    placeholderText: "Enter your email"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    leftPadding: 15
                    color: "white"
                    background: Rectangle {
                        color: "transparent"
                        radius: 10
                        border.width: 1
                        border.color: emailField.activeFocus ? "#4CC9FE" : "#DBE2EF"
                    }
                }
            }

            // Username Input
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true
                Text {
                    text: "USERNAME"
                    color: "#DBE2EF"
                    font.pointSize: 10
                    font.bold: true
                }
                TextField {
                    id: userField
                    placeholderText: "Choose a username"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    leftPadding: 15
                    color: "white"
                    background: Rectangle {
                        color: "transparent"
                        radius: 10
                        border.width: 1
                        border.color: userField.activeFocus ? "#4CC9FE" : "#DBE2EF"
                    }
                }
            }

            // Password Input
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true
                Text {
                    text: "PASSWORD"
                    color: "#DBE2EF"
                    font.pointSize: 10
                    font.bold: true
                }
                TextField {
                    id: passField
                    placeholderText: "Enter password"
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    leftPadding: 15
                    color: "white"
                    background: Rectangle {
                        color: "transparent"
                        radius: 10
                        border.width: 1
                        border.color: passField.activeFocus ? "#4CC9FE" : "#DBE2EF"
                    }
                }
            }

            // Confirm Password
            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true
                Text {
                    text: "CONFIRM PASSWORD"
                    color: "#DBE2EF"
                    font.pointSize: 10
                    font.bold: true
                }
                TextField {
                    id: confirmPassField
                    placeholderText: "Repeat password"
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    leftPadding: 15
                    color: "white"
                    background: Rectangle {
                        color: "transparent"
                        radius: 10
                        border.width: 1
                        border.color: confirmPassField.text !== "" && confirmPassField.text !== passField.text ? "#FF4C4C" : (confirmPassField.activeFocus ? "#4CC9FE" : "#DBE2EF")
                    }
                }
            }

            // Signup Button
            Button {
                id: signupBtn
                text: "SIGN UP"
                Layout.fillWidth: true
                Layout.preferredHeight: 55
                Layout.topMargin: 10

                // makes sure you don't submit when it's empty
                enabled: emailField.text !== "" && userField.text !== "" && passField.text !== "" && passField.text === confirmPassField.text

                contentItem: Text {
                    text: signupBtn.text
                    font.bold: true
                    font.pointSize: 14
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: signupBtn.down ? "#c23a13" : (signupBtn.hovered ? "#f05629" : "#444444")
                    radius: 10
                    border.color: "#4CC9FE"
                    border.width: signupBtn.enabled ? 1 : 0
                }

                onClicked: {
                    signupBtn.text = "CREATING...";
                    signupBtn.enabled = false;
                    authManager.signup(emailField.text, userField.text, passField.text);
                }
            }

            // Footer Link
            Text {
                text: "Already have an Account? Log In"
                color: "#DBE2EF"
                font.pointSize: 10
                Layout.alignment: Qt.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mainNavBar.currentIndex = 4;
                    }
                }
            }
        }
    }
}
