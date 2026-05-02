
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Rectangle {
    id: rect
    color: "transparent"
    visible: mainNavBar.currentIndex === 2
    property bool isLoading: true


    Text {
        id: titleText
        text: "LEADERBOARD"
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.08
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        font.pointSize: 40
        color: "white"
    }

    Row {
        id: mainContainer
        anchors.top: titleText.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60

        width: parent.width * 0.9
        spacing: 30
        Rectangle {
            id: listbackground
            height: parent.height
            width: parent.width - 280

            color: Qt.rgba(17/255, 45/255, 78/255, 0.5) // makes the box have 50% opacity
            radius: 20
            border.color: "#3F72AF"
            border.width: 2
            Row {
                id: filterBar
                spacing: 20

                anchors.bottom: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.bottomMargin: 5

                property bool showingFriends: false

                // Global Tab
                Button {
                    id: globalTab
                    text: "GLOBAL"
                    flat: true
                    onClicked: {
                        if (!rect.isLoading) {
                            filterBar.showingFriends = false
                            rect.isLoading = true
                            authManager.fetchleaderboard()
                        }
                    }
                    contentItem: Text {
                        text: parent.text
                        font.bold: true
                        color: !filterBar.showingFriends ? "#3F72AF" : "white"
                    }
                }

                // Friends Tab
                Button {
                    id: friendsTab
                    text: "FRIENDS"
                    flat: true
                    onClicked:{
                        filterBar.showingFriends = true
                        rect.isLoading = false
                    }
                    contentItem: Text {
                        text: parent.text
                        font.bold: true
                        color: filterBar.showingFriends ? "#3F72AF" : "white"
                    }
                }
            }
            // The Underline Indicator
            Rectangle {
                id: activeIndicator
                height: 3
                color: "#4CC9FE"
                anchors.top: filterBar.bottom
                anchors.topMargin: -2
                width: filterBar.showingFriends ? friendsTab.width : globalTab.width
                x: filterBar.showingFriends ? (filterBar.x + friendsTab.x) : (filterBar.x + globalTab.x)

                // Animations
                Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

                Component.onCompleted: {
                    x = filterBar.showingFriends ? (filterBar.x + friendsTab.x) : (filterBar.x + globalTab.x)
                }
            }
            //Column Headers rank,streak and score
            RowLayout {
                id: headerRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 15
                anchors.leftMargin: 35
                anchors.rightMargin: 35
                spacing: 40
                height: 10

                Text {
                    text: "RANK"
                    font.bold: true
                    font.pointSize: 10
                    color: "#DBE2EF"
                    Layout.preferredWidth: 30
                }

                Text {
                    text: "PLAYER NAME"
                    font.bold: true
                    font.pointSize: 10
                    color: "#DBE2EF"

                    Layout.fillWidth: true
                }
                Text {
                    id: streakHeaderLabel
                    Layout.preferredWidth: 100
                    text: "STREAK"
                    color: "#DBE2EF"
                    font.pointSize: 9
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    text: "SCORE"
                    font.bold: true
                    font.pointSize: 10
                    color: "#DBE2EF"
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 100
                }
            }
            Connections {
                target: authManager
                function onLeaderboardReceived(data) {
                    globalModel.clear();
                    for (var i = 0; i < data.length; i++) {
                        globalModel.append({
                            "username": data[i].username,
                            "xp": data[i].total_xp,
                            "streak": data[i].daily_streak
                        });
                    }
                    rect.isLoading = false;
                }
            }
            Component.onCompleted: {
                rect.isLoading = true;
                authManager.fetchleaderboard();
            }
            ListModel {
                id: globalModel
                ListElement { username: "Loading..."; xp: 0; streak: 0 }
            }

            ListModel {
                id: friendsModel
                ListElement { username: "Friend 1"; streak: "10"; xp: "8030" }
                ListElement { username: "ME"; streak: "7"; xp: "7,450" }
            }

            ListView {
                id:list
                anchors.top: headerRow.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 15

                model: filterBar.showingFriends ? friendsModel : globalModel
                visible: !isLoading

                spacing: 8
                clip: true
                add: Transition {
                    NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 200 }
                    NumberAnimation { properties: "y"; from: 20; duration: 200 }
                }
                delegate: ItemDelegate {
                    width: list.width
                    height: 40
                    background: Rectangle {
                        color: "#3F72AF"
                        radius: 10
                        border.color: "#DBE2EF"
                }
                contentItem: RowLayout{
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 40
                    Item {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30

                        Image {
                            anchors.centerIn: parent
                            width: 60
                            height: 60
                            fillMode: Image.PreserveAspectFit
                            // Show images for index 0, 1, 2
                            visible: index <= 2
                            source: {
                                if (index === 0) return "images/1st.png";
                                if (index === 1) return "images/2nd.png";
                                if (index === 2) return "images/3rd.png";
                                return "";
                            }
                        }

                        Text { //Rank
                            anchors.centerIn: parent
                            // Show number only for index 3 and above
                            visible: index > 2
                            text: index + 1
                            color: "white"
                            font.pointSize: 14
                            font.bold: true
                        }
                    }
                        Text{ //Name
                            text: username
                            color:{
                                if(index+1==1)
                                    return "#C9B037"
                                if(index+1==2)
                                    return "#D7D7D7"
                                if(index+1==3)
                                    return "#CE8946"
                                return "white"
                            }
                            font.pointSize: 14
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        Item {
                            Layout.preferredWidth: 100
                            height: parent.height

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: streak
                                    font.pointSize: 16
                                    color: "white"
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Text {
                                    text: "🔥"
                                    font.pointSize: 14
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                        Text { //Score
                            text: xp
                            font.bold: true
                            font.pointSize: 14
                            color: "#BEE3F8"
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 100
                        }
                    }
                }
            }
            Column {
                    anchors.centerIn: parent
                    visible: rect.isLoading
                    spacing: 10

                    BusyIndicator {
                        id: loadingSpinner
                        running: rect.isLoading
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "FETCHING TOP PLAYERS..."
                        color: "#3F72AF"
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
            }
        }
        //My stats area
        Rectangle {
            id: statsCard
            width: 250
            height: parent.height
            color: Qt.rgba(17/255, 45/255, 78/255, 0.5) // 50% opacity
            radius: 20
            border.color: "#3F72AF"
            border.width: 2


            Column {
                anchors.top: parent.top
                anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.9
                spacing: 15 // Gap between the boxes

                Text {
                    text: "MY STATS"
                    color: "white"
                    font.bold: true
                    font.pointSize: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    bottomPadding: 10
                }

                // Rank Box
                Rectangle {
                    width: parent.width
                    height: 70
                    color: "#3F72AF"
                    radius: 10
                    border.color: "#DBE2EF"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 20 // Padding
                        Text { text: "CURRENT RANK"; color: "#DBE2EF"; font.pointSize: 9; font.bold: true }
                        Text { text: "#42"; color: "#C9B037"; font.pointSize: 20; font.bold: true }
                    }
                }

                // Score Box
                Rectangle {
                    width: parent.width
                    height: 70
                    color: "#3F72AF"
                    radius: 10
                    border.color: "#DBE2EF"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 20
                        Text { text: "TOTAL SCORE"; color: "#DBE2EF"; font.pointSize: 9; font.bold: true }
                        Text { text: userxp; color: "white"; font.pointSize: 20; font.bold: true }
                    }
                }

                // Streak Box
                Rectangle {
                    width: parent.width
                    height: 70
                    color: "#3F72AF"
                    radius: 10
                    border.color: "#DBE2EF"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 20
                        Text { text: "WIN STREAK"; color: "#DBE2EF"; font.pointSize: 9; font.bold: true }
                        Row {
                            spacing: 8
                            Text { text: userstreak; color: "white"; font.pointSize: 20; font.bold: true }
                            Text { text: "🔥"; font.pointSize: 16; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }

                //Progress Bar Box
                Rectangle {
                    width: parent.width
                    height: 70
                    color: "#3F72AF"
                    radius: 10
                    border.color: "#DBE2EF"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 20
                        spacing: 8
                        Text { text: "XP TO NEXT RANK"; color: "#DBE2EF"; font.pointSize: 9 }

                        Rectangle {
                            width: parent.width
                            height: 8
                            color: "#112D4E" // Background of progress bar
                            radius: 4
                            Rectangle {
                                width: parent.width * 0.65
                                height: parent.height
                                color: "#4CC9FE"
                                radius: 4
                            }
                        }

                    }
                }
            }
        }
    }
}
