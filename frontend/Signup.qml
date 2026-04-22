import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: signupPage
    anchors.fill: parent
    color: "transparent"
    anchors.bottomMargin: 50
    property string currentError: ""
    property bool isProcessing: false

    Connections {
        target: authManager

        function onSignupSuccess(totalXp) {
            console.log("Signup Success! User XP: " + totalXp);
            isProcessing = false;

            isLoggedIn = true;
            mainNavBar.currentIndex = 0;
        }

        function onSignupFailed(errorMessage) {
            console.log("Signup Failed: " + errorMessage);
            isProcessing = false;
            currentError= errorMessage;
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
        height: signupColumn.implicitHeight + 80 //so that the error lines can fit
        anchors.top: signupTitle.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        color: Qt.rgba(17 / 255, 45 / 255, 78 / 255, 0.5) // makes the box have 50% opacity
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

            // Email input field
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
            //Error message if email is invalid
            Text {
                id: emailerror
                text: currentError.toLowerCase().includes("email") ? currentError : "" 
                color: "#FF4C4C" 
                font.pointSize: 10
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: text !== "" 
            }

            // Username input field
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
            Text {
                id: usernameerror
                text: currentError.toLowerCase().includes("username") ? currentError : "" 
                color: "#FF4C4C" 
                font.pointSize: 10
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: text !== "" 
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
            //Error message if password is less than 8 characters
            Text {
                id: passworderror
                text: currentError.toLowerCase().includes("password") ? currentError : "" 
                color: "#FF4C4C" 
                font.pointSize: 10
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: text !== "" 
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
                text: isProcessing ? "CREATING..." : "SIGN UP"
                Layout.fillWidth: true
                Layout.preferredHeight: 55
                Layout.topMargin: 10

                // makes sure you don't submit when it's empty
                enabled: !isProcessing && emailField.text !== "" && userField.text !== "" && passField.text !== "" && passField.text === confirmPassField.text

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
                    currentError = "";
                    isProcessing = true;
                    authManager.signup(emailField.text, userField.text, passField.text);
                }
            }

            // Footer link that allows you to go login 
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
