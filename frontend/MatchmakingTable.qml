import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: matchmakingRoot
    property int selectedIndex: -1
    signal missionStarted(int languageIndex, int difficulty)
    color: "transparent"
    Text {
        id: titleText
        text: qsTr("SELECT MATCH LANGUAGE")
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        font.pointSize: 32
        color: "white"
        font.letterSpacing: 2
    }

    // brand color is for if we'll make it use themes for each language at some point
    ListModel {
        id: languageModel
        ListElement { name: "Python"; iconPath: "images/python.png"; brandColor: "#FFD43B"}
        ListElement { name: "C++"; iconPath: "images/cpp.png"; brandColor: "#00599C" }
        ListElement { name: "Java"; iconPath: "images/java.png"; brandColor: "#E76F00" }
        ListElement { name: "JavaScript"; iconPath: "images/javascript.png"; brandColor: "#F7DF1E" }
        ListElement { name: "Rust"; iconPath: "images/rust.png"; brandColor: "#DEA584" }
        ListElement { name: "Go"; iconPath: "images/go.png"; brandColor: "#00ADD8" }
        ListElement { name: "C#"; iconPath: "images/csharp.png"; brandColor: "#239120" }
        ListElement { name: "Ruby"; iconPath: "images/Ruby.png"; brandColor: "#CC342D" }
    }

    GridView {
        id: languageGrid
        anchors.top: titleText.bottom
        anchors.topMargin: 20

        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter

        height: contentHeight
        width: Math.min(cellWidth * 4, cellWidth * Math.floor((parent.width - 40) / cellWidth))
        cellWidth: 160
        cellHeight: 180
        clip: true
        model: languageModel

        delegate: Item {
            width: languageGrid.cellWidth
            height: languageGrid.cellHeight

            Rectangle {
                id: card
                anchors.centerIn: parent
                width: 130
                height: 150
                color: matchmakingRoot.selectedIndex === index ? "#3F72AF" : "#112D4E"
                radius: 15
                border.width: matchmakingRoot.selectedIndex === index ? 3 : 1
                border.color: matchmakingRoot.selectedIndex === index ? "white" : "#335b8c"

                Behavior on color { ColorAnimation { duration: 150 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 15

                    Image {
                        source: iconPath
                        width: 80
                        height: 80
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: name
                        color: "white"
                        font.pointSize: 14
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: matchmakingRoot.selectedIndex = index
                    onEntered: card.scale = 1.05
                    onExited: card.scale = 1.0
                }

                Behavior on scale { NumberAnimation { duration: 100 } }
            }
        }
    }
    Text {
        id: titleText2
        text: qsTr("SELECT MATCH DIFFICULTY")
        anchors.top: languageGrid.bottom
        anchors.horizontalCenter: parent.horizontalCenter
         anchors.topMargin: 20
        font.bold: true
        font.pointSize: 24
        color: "white"
        font.letterSpacing: 2
    }
    Row {
        id: difficultyRow
        anchors.top: titleText2.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 15

        property int selectedDiff: -1 // 0: Easy, 1: Med, 2: Hard

        Repeater {
            model: ["EASY", "MEDIUM", "HARD"]
            delegate: Rectangle {
                width: 120
                height: 45
                radius: 8
                color: difficultyRow.selectedDiff === index ? "#3F72AF" : "#112D4E"
                border.color: difficultyRow.selectedDiff === index ? "#4CC9FE" : "#335b8c"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: "white"
                    font.bold: true
                    font.letterSpacing: 1
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: difficultyRow.selectedDiff = index
                }

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    Button {
        id: blastOffBtn
        anchors.top: difficultyRow.bottom
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        width: 250
        height: 60
        enabled: matchmakingRoot.selectedIndex !== -1 && difficultyRow.selectedDiff !== -1

        onClicked: {
            missionStarted(matchmakingRoot.selectedIndex, difficultyRow.selectedDiff)
        }

        contentItem: Text {
            text: qsTr("START GAME 🚀")
            color: "white"
            font.pointSize: 18
            font.bold: true
            font.letterSpacing: 1
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            opacity: blastOffBtn.enabled ? 1.0 : 0.5
        }

        background: Rectangle {
            radius: 30
            color: blastOffBtn.enabled ? (blastOffBtn.pressed ? "#c23a13" : (blastOffBtn.hovered ? "#f05629" : "#E25822")) : "#444444"
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
}


