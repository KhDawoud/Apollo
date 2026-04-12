import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: explanationPage
    color: "transparent"

    property string missionName: "Unknown Mission"
    property string language: "Unknown"

    // this will stored as markdown from the database
    property var pageData: [
        {
            title: "1. The Theory",
            content: "# " + missionName + "\n\nBefore writing code, let's look at the underlying logic: A brute force approach might check every combination, resulting in an O(n<sup>2</sup>) time complexity. \n\n Can we do better by tracking the state as we iterate?"
        },
        {
            title: "2. Relevant Techniques",
            content: "### Fast Lookups\nBy trading space for time, we can drop our time complexity to $O(n)$.\n\n* **Step 1:** Iterate through the structure.\n* **Step 2:** Check if the required condition is already in our history.\n* **Step 3:** If not, store the current state and move on."
        },
        {
            title: "3. Language Properties",
            content: "### Using " + language + " Effectively\nMake sure to use the correct data structures native to " + language + " to ensure $O(1)$ lookup times. Avoid standard arrays for lookups if a dictionary, map, or set is available."
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "← Back to Problems"
                onClicked: explanationPage.StackView.view.pop()
                background: Rectangle { color: "transparent" }
                contentItem: Text {
                    text: parent.text
                    color: "#94A3B8"
                    font.bold: true
                    font.pixelSize: 16
                }
            }

            Item { Layout.fillWidth: true }

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
                        model: explanationPage.pageData

                        delegate: Item {

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16

                                Text {
                                    text: modelData.title
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

                                    Text {
                                        width: textScrollView.availableWidth

                                        text: modelData.content
                                        textFormat: Text.MarkdownText
                                        color: "#D4D4D4"
                                        font.pixelSize: 18
                                        wrapMode: Text.WordWrap
                                        onLinkActivated: (link) => Qt.openUrlExternally(link)
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
                        background: Rectangle { color: "transparent" }
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#94A3B8" : "#334155"
                            font.bold: true
                        }
                    }

                    PageIndicator {
                        id: indicator
                        count: swipeView.count
                        currentIndex: swipeView.currentIndex
                        Layout.alignment: Qt.AlignHCenter

                        delegate: Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: index === indicator.currentIndex ? "#60A5FA" : "#334155"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    Button {
                        text: "Next ▶"
                        enabled: swipeView.currentIndex < swipeView.count - 1
                        onClicked: swipeView.incrementCurrentIndex()
                        background: Rectangle { color: "transparent" }
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
            Item { Layout.fillWidth: true }

            Button {
                text: "ENTER IDE ➔"
                Layout.preferredHeight: 50
                Layout.preferredWidth: 200

                background: Rectangle {
                    color: parent.down ? "#047857" : (parent.hovered ? "#34D399" : "#10B981")
                    radius: 8
                    Behavior on color { ColorAnimation { duration: 100 } }
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
                        "missionName": explanationPage.missionName,
                        "language": explanationPage.language
                    })
                }
            }
        }
    }
}
