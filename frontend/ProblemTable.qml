//Problems Tables
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: problemsPage
    color: "transparent"

    Connections {
        target: authManager
        function onFetchProblemsListSuccess(problems) {
            missionsModel.clear();
            topicModel.clear();
            difficultyModel.clear();
            topicModel.append({
                name: "All"
            });
            difficultyModel.append({
                name: "All"
            });

            let seenTopic = {};
            let seenDifficulty = {};

            for (let i = 0; i < problems.length; i++) {
                missionsModel.append(problems[i]);

                let topic = problems[i].topic;
                if (!seenTopic[topic]) {
                    seenTopic[topic] = true;
                    topicModel.append({
                        name: topic
                    });
                }

                let difficulty = problems[i].difficulty;
                if (!seenDifficulty[difficulty]) {
                    seenDifficulty[difficulty] = true;
                    difficultyModel.append({
                        name: difficulty
                    });
                }
            }

            rebuildModel();
        }

        function onFetchProblemsListFailed(error) {
            console.log("Failed to fetch problems: " + error);
        }
    }

    property string language: "Unknown"
    property string selectedTopic: "All"
    property string selectedDifficulty: "All"
    property string sortKey: "name"
    property bool sortAscending: true

    ListModel {
        id: missionsModel
    }

    ListModel {
        id: topicModel
    }

    ListModel {
        id: difficultyModel

        ListElement {
            name: "All"
        }
        ListElement {
            name: "Easy"
        }
        ListElement {
            name: "Medium"
        }
        ListElement {
            name: "Hard"
        }
    }

    ListModel {
        id: filteredModel
    }

    function rebuildModel() {
        let temp = [];

        for (let i = 0; i < missionsModel.count; i++) {
            let item = missionsModel.get(i);

            if ((selectedTopic === "All" || item.topic === selectedTopic) && (selectedDifficulty === "All" || item.difficulty === selectedDifficulty)) {
                let color = item.difficulty === "Easy" ? "#10B981" : item.difficulty === "Medium" ? "#F59E0B" : "#EF4444";

                temp.push({
                    id: item.id,
                    name: item.name,
                    topic: item.topic,
                    difficulty: item.difficulty,
                    diffColor: color,
                    completed: item.completed
                });
            }
        }

        temp.sort(function (a, b) {
            let valA = a[sortKey];
            let valB = b[sortKey];

            if (sortKey === "difficulty") {
                const order = {
                    "Easy": 1,
                    "Medium": 2,
                    "Hard": 3
                };

                valA = order[valA];
                valB = order[valB];

                return sortAscending ? valA - valB : valB - valA;
            }

            let result = String(valA).localeCompare(String(valB));
            return sortAscending ? result : -result;
        });

        filteredModel.clear();

        for (let i = 0; i < temp.length; i++)
            filteredModel.append(temp[i]);
    }

    onSelectedTopicChanged: rebuildModel()
    onSelectedDifficultyChanged: rebuildModel()
    onSortKeyChanged: rebuildModel()
    onSortAscendingChanged: rebuildModel()

    Component.onCompleted: authManager.fetchProblemsList(language)

    RowLayout {
        id: headerRow

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20

        Button {
            text: "← Back"

            onClicked: problemsPage.StackView.view.pop()

            background: Rectangle {
                color: "transparent"
            }

            contentItem: Text {
                text: parent.text
                color: "#94A3B8"
                font.bold: true
            }
        }

        Text {
            Layout.fillWidth: true
            text: "MISSIONS: " + language.toUpperCase()

            color: "white"
            font.pointSize: 20
            font.bold: true

            horizontalAlignment: Text.AlignRight
        }
    }

    Rectangle {
        id: filterBar

        anchors.top: headerRow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 40
        anchors.topMargin: 10

        height: 60
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            spacing: 12

            Button {
                id: topicButton

                text: "Topic: " + selectedTopic
                height: 36

                contentItem: Text {
                    text: parent.text + "  ▾"
                    color: "white"
                    font.bold: true
                    leftPadding: 12
                    rightPadding: 12
                }

                background: Rectangle {
                    radius: 18
                    color: "#1E293B"
                    border.color: "#334155"
                }

                onClicked: topicMenu.open()

                Popup {
                    id: topicMenu

                    y: parent.height + 6
                    width: 160
                    padding: 8

                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                    background: Rectangle {
                        color: "#ffffff"
                        radius: 8
                        border.color: "#cccccc"
                    }

                    contentItem: Column {
                        width: parent.width

                        Repeater {
                            model: topicModel

                            Button {
                                width: parent.width
                                height: 36
                                hoverEnabled: true

                                onClicked: {
                                    selectedTopic = model.name;
                                    topicMenu.close();
                                }

                                contentItem: Text {
                                    text: model.name
                                    color: "#333"
                                    leftPadding: 12
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    radius: 6
                                    color: parent.hovered ? "#f2f2f2" : "transparent"
                                }
                            }
                        }
                    }
                }
            }

            Button {
                id: difficultyButton

                text: "Difficulty: " + selectedDifficulty
                height: 36

                contentItem: Text {
                    text: parent.text + "  ▾"
                    color: "white"
                    font.bold: true
                    leftPadding: 12
                    rightPadding: 12
                }

                background: Rectangle {
                    radius: 18
                    color: "#1E293B"
                    border.color: "#334155"
                }

                onClicked: difficultyMenu.open()

                Popup {
                    id: difficultyMenu

                    y: parent.height + 6
                    width: 140
                    padding: 8

                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                    background: Rectangle {
                        color: "#ffffff"
                        radius: 8
                        border.color: "#cccccc"
                    }

                    contentItem: Column {
                        width: parent.width

                        Repeater {
                            model: difficultyModel

                            Button {
                                width: parent.width
                                height: 36
                                hoverEnabled: true

                                onClicked: {
                                    selectedDifficulty = model.name;
                                    difficultyMenu.close();
                                }

                                contentItem: Text {
                                    text: model.name
                                    color: "#333"
                                    leftPadding: 12
                                }

                                background: Rectangle {
                                    radius: 6
                                    color: parent.hovered ? "#f2f2f2" : "transparent"
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }

    Rectangle {
        anchors.top: filterBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 40
        anchors.topMargin: 10

        color: "#131E30"
        radius: 12
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#1E293B"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 3

                        Row {
                            anchors.centerIn: parent

                            Text {
                                text: "MISSION NAME"
                                color: "#94A3B8"
                                font.bold: true
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1.5

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "TOPIC"
                                color: "#94A3B8"
                                font.bold: true
                            }

                            Text {
                                text: sortKey === "topic" ? (sortAscending ? "▲" : "▼") : ""
                                color: "#60A5FA"
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (sortKey === "topic")
                                    sortAscending = !sortAscending;
                                else {
                                    sortKey = "topic";
                                    sortAscending = true;
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "DIFFICULTY"
                                color: "#94A3B8"
                                font.bold: true
                            }

                            Text {
                                text: sortKey === "difficulty" ? (sortAscending ? "▲" : "▼") : ""
                                color: "#60A5FA"
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (sortKey === "difficulty")
                                    sortAscending = !sortAscending;
                                else {
                                    sortKey = "difficulty";
                                    sortAscending = true;
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#334155"
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                model: filteredModel
                clip: true

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 50

                    color: rowMouseArea.containsMouse ? "#334155" : (model.completed ? "#102218" : (index % 2 === 0 ? "transparent" : "#1E293B80"))

                    Rectangle {
                        visible: model.completed

                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        width: 4
                        color: "#10B981"
                    }

                    MouseArea {
                        id: rowMouseArea

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onDoubleClicked: {
                            problemsPage.StackView.view.push("MissionExplanation.qml", {
                                "problemId": model.id,
                                "language": problemsPage.language
                            });
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20

                        enabled: false
                        spacing: 12

                        Rectangle {
                            visible: model.completed

                            width: 28
                            height: 28
                            radius: 14

                            color: "#10B981"

                            Text {
                                anchors.centerIn: parent

                                text: "✓"
                                color: "white"

                                font.bold: true
                                font.pixelSize: 16
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 3

                            text: model.name
                            color: "white"

                            font.pixelSize: 14
                            font.bold: model.completed
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1.5

                            text: model.topic
                            color: "#94A3B8"

                            font.pixelSize: 14
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1

                            text: model.difficulty
                            color: model.diffColor

                            font.bold: true
                            font.pixelSize: 14
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#334155"
                        opacity: 0.3
                    }
                }
            }
        }
    }
}
