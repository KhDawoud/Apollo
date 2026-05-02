//Language Select
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: problemsRoot
    property int selectedIndex: -1
    color: "transparent"
    signal languageChosen(string langName)

    Text {
        id: titleText
        text: qsTr("SELECT MISSION LANGUAGE")
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
        ListElement { name: "Ruby"; iconPath: "images/ruby.png"; brandColor: "#CC342D" }
    }

    GridView {
        id: languageGrid
        anchors.top: titleText.bottom
        anchors.topMargin: 40
        anchors.bottom: blastOffBtn.top
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter

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
                color: problemsRoot.selectedIndex === index ? "#3F72AF" : "#112D4E"
                radius: 15
                border.width: problemsRoot.selectedIndex === index ? 3 : 1
                border.color: problemsRoot.selectedIndex === index ? "white" : "#335b8c"

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
                    onClicked: problemsRoot.selectedIndex = index
                    onEntered: card.scale = 1.05
                    onExited: card.scale = 1.0
                }

                Behavior on scale { NumberAnimation { duration: 100 } }
            }
        }
    }

    Button {
        id: blastOffBtn
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        width: 250
        height: 60
        enabled: problemsRoot.selectedIndex !== -1

        onClicked: {
            var langName = languageModel.get(problemsRoot.selectedIndex).name
            problemsRoot.languageChosen(langName)
        }

        contentItem: Text {
            text: qsTr("BLAST OFF 🚀")
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
