import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: qsTr("Apollo")

    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "#262626"

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
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 30
            anchors.rightMargin: 20
            background: Item {}

            component ApolloTab: TabButton {
                            id: control
                            font.styleName: "Bold"
                            font.weight: Font.Bold
                            font.pointSize: 14
                            display: AbstractButton.TextOnly
                            hoverEnabled: true
                            width: mainNavBar.width / 5
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

                                // 3. Add a smooth fade animation when the color changes
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
            ApolloTab { text: qsTr("Profile") }
        }
    }
}
