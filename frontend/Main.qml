import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: qsTr("Apollo")
    visibility: Window.Maximized
    property bool isLoggedIn: true

    Rectangle {
        id: masterBackground
        anchors.fill: parent
        color: "#000015"

        Item {
            id: globalStarfield
            anchors.fill: parent

            Repeater {
                model: 170
                Rectangle {
                    property int animDuration: Math.random() * 5000 + 1000
                    x: Math.random() * globalStarfield.width
                    y: Math.random() * globalStarfield.height
                    width: Math.random() * 3 + 1
                    height: width
                    radius: width / 2
                    color: "#D7D7D7"
                    opacity: Math.random()

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { to: 1.0; duration: animDuration; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.1; duration: animDuration; easing.type: Easing.InOutSine }
                    }
                }
            }
        }
    }



    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "transparent"
        visible: mainstacklayout.currentIndex < 4 
        height: visible ? 80 : 0

        Image {
            id: apollologo
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            width: 80
            height: 80
            source: "images/logo.png"
            fillMode: Image.PreserveAspectFit
        }

        TabBar {
            id: mainNavBar
            anchors.left: apollologo.right
            width: implicitWidth
            // --- FIX 2: Anchor the right side to the profile button to prevent overlap ---
            anchors.right: profilearea.left

            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 30
            anchors.rightMargin: 20
            spacing: 23
            background: Item {}
            currentIndex: 0
            onCurrentIndexChanged: {
                if (!isLoggedIn && (currentIndex === 1 || currentIndex === 2|| currentIndex === 3)) {
                    console.log("Access denied. Please log in.")
                    currentIndex = 6 
                }
            }

            component ApolloTab: TabButton {
                id: control
                font.styleName: "Bold"
                font.weight: Font.Bold
                font.pointSize: 14
                display: AbstractButton.TextOnly
                hoverEnabled: true

                // --- FIX 1: Break the loop by sizing based on the text content, not the TabBar ---
                implicitWidth: Math.max(120, contentItem.implicitWidth + 40)
                height: 50

                contentItem: Text {
                    font: control.font
                    color: "white"
                    text: control.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: control.checked ? "#134ec0" : (control.hovered ? "#22ffffff" : "transparent")
                    radius: 8

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            ApolloTab { text: qsTr("Home") }
            ApolloTab { text: qsTr("Problems") }
            ApolloTab { text: qsTr("Leaderboard") }
            ApolloTab { text: qsTr("MatchFinder") }
        }

        Item{
            id: profilearea
            width: 120
            height: 50
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            Button {
                id: signInButton
                visible: !isLoggedIn
                text: "Sign In"
                anchors.fill: parent
                onClicked: mainNavBar.currentIndex = 4
                display: AbstractButton.TextOnly
                hoverEnabled: true
                background: Rectangle {
                    color: signInButton.checked ? "#134ec0" : (signInButton.hovered ? "#22ffffff" : "transparent")
                    radius: 8

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                    }
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    font.styleName: "Bold"
                    font.weight: Font.Bold
                    font.pointSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                id: profileButton
                visible: isLoggedIn
                anchors.right: parent.right
                anchors.rightMargin: 20
                width: 50
                height: 50
                z: 10
                hoverEnabled: true

                // 1. The Dropdown Menu
                // 1. The Custom Dropdown (No hidden Qt Menu formatting!)
                Popup {
                    id: profileMenu
                    x: profileButton.width - width + 20
                    y: profileButton.height + 7
                    width: 160

                    // Strip ALL default invisible borders
                    padding: 10
                    margins: 0

                    // Automatically closes if you click outside of it
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                    // The White Background Area
                    background: Rectangle {
                        color: "#ffffff"
                        radius: 8
                        border.color: "#cccccc"
                    }

                    // The Content Area
                    contentItem: Column {
                        width: parent.width
                        // Tiny padding so the top/bottom buttons don't clip your rounded corners
                        topPadding: 4
                        bottomPadding: 4

                        // --- Item 1: My Account ---
                        Button {
                            width: parent.width
                            height: 40
                            hoverEnabled: true
                            onClicked: profileMenu.close() // Close menu when clicked

                            contentItem: Text {
                                text: qsTr("My Account")
                                color: "#333333"
                                font.pointSize: 13
                                font.weight: Font.DemiBold
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 15
                            }

                            background: Rectangle {
                                color: parent.hovered ? "#f2f2f2" : "transparent"
                                radius: 6

                            }
                        }

                        // --- Light Gray Separator ---
                        Item {
                            width: parent.width
                            height: 11 // 5px top gap + 1px line + 5px bottom gap

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#e0e0e0"
                                anchors.verticalCenter: parent.verticalCenter // Centers the line in the gap
                            }
                        }

                        // --- Item 2: Settings ---
                        Button {
                            width: parent.width
                            height: 40
                            hoverEnabled: true
                            onClicked: profileMenu.close()

                            contentItem: Text {
                                text: qsTr("Settings")
                                color: "#333333"
                                font.pointSize: 13
                                font.weight: Font.DemiBold
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 15
                            }

                            background: Rectangle {
                                color: parent.hovered ? "#f2f2f2" : "transparent"
                                radius: 6
                            }
                        }

                        // --- Light Gray Separator ---
                        Item {
                            width: parent.width
                            height: 11 // 5px top gap + 1px line + 5px bottom gap

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#e0e0e0"
                                anchors.verticalCenter: parent.verticalCenter // Centers the line in the gap
                            }
                        }

                        // --- Item 3: Log Out ---
                        Button {
                            width: parent.width
                            height: 40
                            hoverEnabled: true
                            onClicked:{
                                profileMenu.close()
                                isLoggedIn = false
                                mainNavBar.currentIndex = 0
                            }
                            contentItem: Text {
                                text: qsTr("Log Out")
                                color: "#d93025"
                                font.pointSize: 13
                                font.weight: Font.DemiBold
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 15
                            }

                            background: Rectangle {
                                color: parent.hovered ? "#fdf0ef" : "transparent"
                                radius: 6
                            }
                        }
                    }
                }

                // Open the menu when the button is clicked
                onClicked: profileMenu.open()

                // 2. The Custom Profile Picture and Animated Ring
                background: Item {
                    // The Animated Ring
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        radius: width / 2
                        color: "transparent"

                        // Shows border when hovered OR when the menu is actively open
                        border.width: profileButton.hovered || profileMenu.opened ? 3 : 0
                        border.color: "#134ec0"

                        // Expands slightly when hovered
                        scale: profileButton.hovered || profileMenu.opened ? 1.15 : 1.0

                        // Smooth animations for the ring
                        Behavior on border.width { NumberAnimation { duration: 150 } }
                        Behavior on scale {
                            NumberAnimation { duration: 200; easing.type: Easing.OutBack }
                        }
                    }

                    // The Profile Image
                    Image {
                        anchors.centerIn: parent
                        width: parent.width // Scaled down to fit inside the ring
                        height: parent.height
                        source: "images/defaultpfp.png"
                        fillMode: Image.PreserveAspectCrop
                    }
                }
            }
        }
    }
    StackLayout {
        id: mainstacklayout
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        currentIndex: mainNavBar.currentIndex // This links the TabBar to the content


        // Index 0: Home
        Home {
                onGoToProblems: mainNavBar.currentIndex = 1  // listen for the signal
                onGoToLeaderboard: mainNavBar.currentIndex = 2
                onGoToMatchFinder: mainNavBar.currentIndex = 3
                onGoToProgress: mainNavBar.currentIndex = 2 // till progress secion created as seperate page or in smth else
            }

        // Index 1: Problems
        Problems { }

        // Index 2: Leaderboard
        LeaderBoard { }

        // Index 3: MatchFinder
        Rectangle { color: "transparent"; Text { text: "MatchFinder Page"; color: "white"; anchors.centerIn: parent } }

        //Index 4: Login
        Login{}
        //Index 5: Signup
        Signup{}
        //Index 6: Welcome
        Welcome{}
    }
}
