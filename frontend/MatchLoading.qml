import QtQuick

import QtQuick.Controls

Item {
    id: loadingRoot

    // data passed from selection Page
    property int gameLanguage: 0
    property int gameDifficulty: 0
    property string username: "name"
    property int userxp: 0
    property int userstreak: 0

    property string foundOpponentName: "???"
    property string foundOpponentXp: "0"
    property string foundOpponentStreak: "0"


    property var opponentNames: ["CyberOrbit", "StellarCoder", "LunaDev", "Nebula99", "ApolloAce"]
    ListModel {
        id: problemsModel
    }
    function languageName() {
        var languages = ["Python", "C++", "Java", "JavaScript", "Rust", "Go", "C#", "Ruby"]
        return languages[gameLanguage]
    }

    Component.onCompleted: authManager.fetchProblemsList(languageName())

    Connections {
        target: authManager
        function onFetchProblemsListSuccess(problems) {
            var difficultyMap = ["Easy", "Medium", "Hard"]
            var selectedDifficulty = difficultyMap[gameDifficulty]

            problemsModel.clear()
            for (let i = 0; i < problems.length; i++) {
                if (problems[i].difficulty === selectedDifficulty) {
                    problemsModel.append(problems[i])
                }
            }
        }
        function onFetchProblemsListFailed(error) {
            console.log("Failed to fetch problems: " + error)
        }
    }


    Item {
        id: centerGroup
        width: 800
        height: 400
        anchors.centerIn: parent


        // Your Profile
        Column {
            id: playerOne
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 15

            Rectangle {
                width: 180
                height: 180
                radius: 90
                color: "#1a1a1a"
                border.color: "white"
                border.width: 3
                clip: true
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: profileImage
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: "images/defaultpfp.png"
                    fillMode: Image.PreserveAspectCrop
                }
            }
            Text {
                    text: username
                    color: "white"
                    font.pointSize: 18
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: 200
                    elide: Text.ElideRight // adds "..." if the name is too long
                }
            Column {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    spacing: 5
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "XP:"
                        color: "#4CC9FE"
                        font.pointSize: 12
                        font.bold: true
                    }
                    Text {
                        text: userxp
                        color: "white"
                        font.pointSize: 14
                    }
                }

                Rectangle {
                    width: streakText.width + 20
                    height: 25
                    color: "#22FF9800" // Transparent orange background
                    radius: 12
                    border.color: "#FF9800"
                    border.width: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: streakText
                        anchors.centerIn: parent
                        text: "🔥 " + userstreak + " DAY STREAK"
                        color: "#FF9800"
                        font.pointSize: 10
                        font.bold: true
                    }
                }
            }
        }

        // The VS Text
        Text {
            id: vsText
            text: "VS"
            font.pointSize: 50
            font.italic: true
            font.weight: Font.Black
            color: "#4CC9FE"
            anchors.centerIn: parent

            // Subtle pulse animation for the VS
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.2; duration: 600; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.2; to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
            }
        }
        Column {
            id: playerTwo
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 15

            Column {
                id: opponentProfile
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 180; height: 180; radius: 90
                    color: "#1a1a1a"
                    border.color: matchTimer.running ? "#444" : "#EF4444"
                    border.width: 3
                    clip: true
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "?"
                        font.pointSize: 60
                        color: "#444"
                        anchors.centerIn: parent
                        visible: matchTimer.running
                    }

                    Image {
                        anchors.fill: parent
                        source: "images/defaultpfp.png"
                        fillMode: Image.PreserveAspectCrop
                        visible: !matchTimer.running
                        layer.enabled: true
                    }
                }
            }

            Text {
                id: opponentNameText
                text: foundOpponentName
                color: "white"
                font.pointSize: 18
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Column {
                spacing: 5
                opacity: matchTimer.running ? 0.3 : 1.0
                anchors.horizontalCenter: parent.horizontalCenter

                Row {
                    spacing: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    Text { text: "XP:"; color: "#EF4444"; font.bold: true; font.pointSize: 12 }
                    Text {
                        text: foundOpponentXp
                        color: "white"; font.pointSize: 14
                    }
                }

                Rectangle {
                    width: oppStreakText.width + 20
                    height: 25
                    color: matchTimer.running ? "#11ffffff" : "#22EF4444"
                    radius: 12
                    border.color: matchTimer.running ? "#33ffffff" : "#EF4444"
                    border.width: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: oppStreakText
                        anchors.centerIn: parent
                        text: "⚔️ " + foundOpponentStreak + " STREAK"
                        color: matchTimer.running ? "#666" : "#EF4444"
                        font.pointSize: 10
                        font.bold: true
                    }
                }
            }
        }

        // THE PROBLEM ROULETTE
        Rectangle {
            id: problemBox
            width: 400
            height: 50
            color: "#22ffffff"
            radius: 5
            anchors.top: vsText.bottom
            anchors.topMargin: 120
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: problemText
                anchors.centerIn: parent
                text: "Scanning Problems..."
                color: "white"
                font.pointSize: 14
                font.family: "Monospace"
            }
        }
    }

    // TIMERS

    Timer {
        id: matchTimer
        interval: 80
        running: true
        repeat: true
        onTriggered: {
            // fast rolling text
            opponentNameText.text = opponentNames[Math.floor(Math.random() * opponentNames.length)]
            if (problemsModel.count > 0) {
                var idx = Math.floor(Math.random() * problemsModel.count)
                problemText.text = "> " + problemsModel.get(idx).name
            }
            foundOpponentXp = Math.floor(Math.random() * 9999)
            foundOpponentStreak = Math.floor(Math.random() * 20)
        }
    }

    Timer {
        id: stopTimer
        interval: 3500 // 3.5 seconds of searching
        running: true
        onTriggered: {
            matchTimer.stop()
            foundOpponentName = "CyberStriker_01" //these will be fetched later
            foundOpponentXp = "12,450"
            foundOpponentStreak = "12"
            var idx = Math.floor(Math.random() * problemsModel.count)
            problemText.text = "SELECTED: " + problemsModel.get(idx).name

            // wait 1 second after finding, then go to the game
            finalTransition.start()
        }
    }

    Timer {
        id: finalTransition
        interval: 1500
        //onTriggered: mainStack.push("ActualGame.qml") here we will add the actual match
    }
}
