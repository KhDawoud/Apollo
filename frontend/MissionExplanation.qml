import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: explanationPage
    color: "transparent"

    property int problemId: 0
    property string missionName: ""
    property string language: "Unknown"
    property string missionDescription: ""
    property string initialCode: ""

    ListModel {
        id: pageModel
    }

    Connections {
        target: authManager

        function onFetchProblemSuccess(problem) {
            console.log("lessons length: " + problem.lessons.length);
            missionName = problem.name;
            missionDescription = problem.description;
            initialCode = problem.initial_code;
            console.log("RAW CONTENT: " + problem.lessons[0].content);

            pageModel.clear();
            for (let i = 0; i < problem.lessons.length; i++) {
                pageModel.append({
                    title: problem.lessons[i].title,
                    content: problem.lessons[i].content
                });
            }
            console.log("pageModel count after fill: " + pageModel.count);
        }

        function onFetchProblemFailed(error) {
            console.log("Failed to fetch problem: " + error);
        }
    }

    Component.onCompleted: authManager.fetchProblem(problemId)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "← Back to Problems"
                onClicked: explanationPage.StackView.view.pop()
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

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "BRIEFING: " + missionName.toUpperCase()
                color: "white"
                font.pointSize: 20
                font.bold: true
                horizontalAlignment: Text.AlignRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#131E30"
            radius: 12
            border.color: "#334155"
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                SwipeView {
                    id: swipeView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Repeater {
                        model: pageModel

                        delegate: Item {
                            width: swipeView.width
                            height: swipeView.height
                            property string slideContent: model.content  // ← capture it here

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16

                                Text {
                                    text: model.title
                                    color: "#60A5FA"
                                    font.pixelSize: 24
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                ScrollView {
                                    id: textScrollView
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                                    contentWidth: availableWidth

                                    Column {
                                        width: textScrollView.availableWidth
                                        spacing: 12

                                        Repeater {
                                            model: slideContent.split("```")

                                            delegate: Loader {
                                                width: parent.width
                                                property bool isCode: index % 2 === 1
                                                property string displayText: modelData.trim()
                                                sourceComponent: isCode ? codeBlock : textBlock
                                                Component.onCompleted: console.log("BLOCK " + index + " isCode=" + isCode + " text=" + displayText.substring(0, 50))
                                            }
                                        }

                                        Component {
                                            id: textBlock
                                            Text {
                                                width: parent.width
                                                text: displayText.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\n/g, "<br>")
                                                textFormat: Text.StyledText
                                                color: "#D4D4D4"
                                                font.pixelSize: 18
                                                wrapMode: Text.WordWrap
                                            }
                                        }

                                        Component {
                                            id: codeBlock
                                            CodeEditor {
                                                width: parent.width
                                                height: Math.max(80, displayText.split("\n").length * 24 + 32)
                                                text: displayText
                                                readOnly: true
                                                fontSize: 14
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter

                    Button {
                        text: "◀ Prev"
                        enabled: swipeView.currentIndex > 0
                        onClicked: swipeView.decrementCurrentIndex()
                        background: Rectangle {
                            color: "transparent"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#94A3B8" : "#334155"
                            font.bold: true
                        }
                    }

                    PageIndicator {
                        id: indicator
                        count: pageModel.count
                        currentIndex: swipeView.currentIndex
                        Layout.alignment: Qt.AlignHCenter

                        delegate: Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: index === indicator.currentIndex ? "#60A5FA" : "#334155"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }
                    }

                    Button {
                        text: "Next ▶"
                        enabled: swipeView.currentIndex < pageModel.count - 1
                        onClicked: swipeView.incrementCurrentIndex()
                        background: Rectangle {
                            color: "transparent"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#94A3B8" : "#334155"
                            font.bold: true
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Item {
                Layout.fillWidth: true
            }

            Button {
                text: "ENTER IDE ➔"
                Layout.preferredHeight: 50
                Layout.preferredWidth: 200

                background: Rectangle {
                    color: parent.down ? "#047857" : (parent.hovered ? "#34D399" : "#10B981")
                    radius: 8
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    explanationPage.StackView.view.push("MissionSolver.qml", {
                        "problemId": explanationPage.problemId.toString(),
                        "missionDescription": explanationPage.missionDescription,
                        "initialCode": explanationPage.initialCode.replace(/\\n/g, "\n"),
                        "language": explanationPage.language,
                        "missionName": explanationPage.missionName
                    });
                }
            }
        }
    }
}
