import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Apollo.Code

Rectangle {
    id: solvingPage
    color: "transparent"

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
                background: Rectangle { color: "transparent" }
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
            language: "cpp" //eventually we'll pass down which language specifcally we are using
        }

        RowLayout {
            id: bottomBar
            Layout.fillWidth: true
            spacing: 16

            Item { Layout.fillWidth: true }

            Button {
                id: runButton
                text: "Run Code"
                Layout.preferredWidth: 120
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
                }
            }

            Button {
                id: launchButton
                text: "LAUNCH"
                Layout.preferredWidth: 140
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

                onClicked: {
                }
            }
        }
    }
}
