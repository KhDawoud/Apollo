import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: welcomePage
    anchors.fill: parent
    color: "transparent"

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
    RowLayout {
        anchors.centerIn: parent
        spacing: 80 // Space between the logo and the buttons
        width: parent.width * 0.85
        height: parent.height * 0.7

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4 
            color: "transparent" 

            Image {
                id: largeLogo
                source: "images/logo.png" 
                anchors.centerIn: parent
                
                width: parent.width > 0 ? parent.width * 0.8 : 200
                height: width
                
                fillMode: Image.PreserveAspectFit
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 400 
            spacing: 25

            Text {
                text: "SPACE ADVENTURE"
                color: "white"
                font.pointSize: 42
                font.bold: true
                Layout.alignment: Qt.AlignLeft
            }

            Text {
                text: "Join the mission and track your progress."
                color: "#DBE2EF"
                font.pointSize: 14
                Layout.alignment: Qt.AlignLeft
                Layout.bottomMargin: 15
            }

            // LOG IN BUTTON
            Button {
                id: loginBtn
                text: "LOG IN"
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                
                onClicked: mainNavBar.currentIndex = 4

                background: Rectangle {
                    color: "#112D4E"
                    radius: 12
                    border.color: "#4CC9FE"
                    border.width: loginBtn.hovered ? 2 : 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    font.pointSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // SIGN UP BUTTON
            Button {
                id: signupBtn
                text: "CREATE ACCOUNT"
                Layout.fillWidth: true
                Layout.preferredHeight: 60

                onClicked: mainNavBar.currentIndex = 5

                background: Rectangle {
                    color: "transparent"
                    radius: 12
                    border.color: "#DBE2EF"
                    border.width: 1
                    opacity: signupBtn.hovered ? 1.0 : 0.7
                }
                contentItem: Text {
                    text: parent.text
                    color: "#DBE2EF"
                    font.bold: true
                    font.pointSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}