import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Apollo.Code

Rectangle {
    id: solvingPage
    color: "transparent"

    property bool showResultsModal: false
    property int displayedCases: 0
    property bool isEvaluating: false

    // dummy data for now
    property int totalCases: 12
    property int passedCases: 7

    property string language: "Unknown"
    property string missionName: "Array Traversal & State Tracking"
    property string missionDescription: "In this mission, you need to traverse the given array and track the state of the system modules. \n\nWrite a function that returns true if all primary thrusters are operational, otherwise return false. Optimize your solution to run in O(n) time.\n\nExample Input: [1, 1, 0, 1]\nExpected Output: false"
    property string initialCode: "class Solution {\npublic:\n    void checkSolution() {\n       // Write your code here\n       return;\n    }\n};\n"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20

        RowLayout {
            id: headerRow
            Layout.fillWidth: true

            Button {
                text: "← Back"
                onClicked: solvingPage.StackView.view.pop()
                background: Rectangle {
                    color: "transparent"
                }
                contentItem: Text {
                    text: parent.text
                    color: "#94A3B8"
                    font.bold: true
                    font.pixelSize: 16
                }
            }

            Text {
                Layout.fillWidth: true
                text: missionName.toUpperCase()
                color: "white"
                font.pointSize: 20
                font.bold: true
                horizontalAlignment: Text.AlignRight
            }
        }

        Rectangle {
            id: descriptionBox
            Layout.fillWidth: true
            Layout.preferredHeight: descriptionText.implicitHeight + 40
            color: "#131E30"
            radius: 12
            border.color: "#1E293B"

            Text {
                id: descriptionText
                anchors.fill: parent
                anchors.margins: 20
                text: missionDescription
                color: "#CBD5E1"
                font.pixelSize: 16
                wrapMode: Text.WordWrap
                lineHeight: 1.4
            }
        }

        CodeEditor {
            id: myCodeEditor
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: initialCode
        }

        SyntaxHighlighter {
            document: myCodeEditor.textDocument
            language: "cpp"
        }

        RowLayout {
            id: bottomBar
            Layout.fillWidth: true
            spacing: 16

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: runButton
                text: "Run Code ▶"
                Layout.preferredWidth: 130
                Layout.preferredHeight: 44

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.pressed ? "#1D4ED8" : (parent.hovered ? "#2563EB" : "#3B82F6")
                    radius: 8
                }

                onClicked: {
                    solvingPage.displayedCases = 0;
                    solvingPage.isEvaluating = true;
                    solvingPage.showResultsModal = true;
                    simulationTimer.start();
                }
            }

            Button {
                id: launchButton
                text: "LAUNCH 🚀"
                Layout.preferredWidth: 150
                Layout.preferredHeight: 44

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    font.pixelSize: 16
                    font.letterSpacing: 1.5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.pressed ? "#047857" : (parent.hovered ? "#059669" : "#10B981")
                    radius: 8
                }
            }
        }
    }

    // the tests are actually already completed and you have the results but I made
    // it animated so it feels more interactive
    Timer {
        id: simulationTimer
        interval: 100 // was thinking to make this random so it's not obvious the animation is just for show
        repeat: true
        onTriggered: {
            if (solvingPage.displayedCases < solvingPage.totalCases) {
                solvingPage.displayedCases++;
            } else {
                solvingPage.isEvaluating = false;
                stop();
            }
        }
    }

    Rectangle {
        id: resultsOverlay
        anchors.fill: parent
        color: Qt.rgba(0.05, 0.07, 0.12, 0.85)

        opacity: solvingPage.showResultsModal ? 1.0 : 0.0
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (!solvingPage.isEvaluating)
                    solvingPage.showResultsModal = false;
            }
        }

        Rectangle {
            id: resultsModal
            width: 480
            height: 420
            anchors.centerIn: parent
            color: "#0F172A"
            radius: 16
            border.color: solvingPage.isEvaluating ? "#334155" : (passedCases === totalCases ? "#059669" : "#B45309")
            border.width: 2

            Behavior on border.color {
                ColorAnimation {
                    duration: 400
                }
            }

            scale: solvingPage.showResultsModal ? 1.0 : 0.85
            Behavior on scale {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutBack
                }
            }

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Text {
                        text: solvingPage.isEvaluating ? "Evaluating..." : (passedCases === totalCases ? "Mission Accomplished" : "Partial Success")
                        color: solvingPage.isEvaluating ? "#60A5FA" : (passedCases === totalCases ? "#34D399" : "#F59E0B")
                        font.pixelSize: 26
                        font.bold: true
                        font.letterSpacing: 1.0
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#1E293B"
                }

                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    columns: 6
                    rowSpacing: 12
                    columnSpacing: 12

                    Repeater {
                        model: solvingPage.totalCases

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 8
                            color: {
                                if (index >= solvingPage.displayedCases)
                                    return "#1E293B";
                                return index < solvingPage.passedCases ? "#10B981" : "#EF4444";
                            }

                            scale: index < solvingPage.displayedCases ? 1.0 : 0.4
                            opacity: index < solvingPage.displayedCases ? 1.0 : 0.3
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutBack
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: index >= solvingPage.displayedCases ? "" : (index < solvingPage.passedCases ? "✓" : "✗")
                                color: "white"
                                font.bold: true
                                font.pixelSize: 18
                            }
                        }
                    }
                }

                // results of the testing
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "#131E30"
                    radius: 10
                    border.color: "#1E293B"
                    opacity: solvingPage.isEvaluating ? 0.0 : 1.0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20

                        ColumnLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "🎯 Tests Passed"
                                color: "#94A3B8"
                                font.pixelSize: 12
                            }
                            Text {
                                text: passedCases + " / " + totalCases
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                            }
                        }

                        Rectangle {
                            width: 1
                            Layout.fillHeight: true
                            color: "#1E293B"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "⏱️ Runtime"
                                color: "#94A3B8"
                                font.pixelSize: 12
                            }
                            Text {
                                text: "450 ns"
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                            }
                        }

                        Rectangle {
                            width: 1
                            Layout.fillHeight: true
                            color: "#1E293B"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "💾 Memory"
                                color: "#94A3B8"
                                font.pixelSize: 12
                            }
                            Text {
                                text: "1.2 MB"
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Button {
                    text: solvingPage.isEvaluating ? "Processing..." : "Close Terminal"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    enabled: !solvingPage.isEvaluating

                    contentItem: Text {
                        text: parent.text
                        color: solvingPage.isEvaluating ? "#94A3B8" : "white"
                        font.bold: true
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#334155" : (parent.hovered && !solvingPage.isEvaluating ? "#475569" : "#1E293B")
                        radius: 8
                        border.color: solvingPage.isEvaluating ? "#334155" : "#64748B"
                    }

                    onClicked: solvingPage.showResultsModal = false
                }
            }
        }
    }
}
