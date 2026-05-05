import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Apollo.Code
import Apollo.Backend 1.0

Rectangle {
    id: solvingPage
    color: "transparent"

    property string problemId: ""

    property bool showResultsModal: false
    property int displayedCases: 0
    property bool isEvaluating: false

    property int totalCases: 0
    property int passedCases: 0
    property string runtimeMs: "0.00"
    property string stdOutput: ""

    property bool isErrorState: false
    property string errorOutput: ""

    property string language: "cpp"
    property string missionName: ""
    property string missionDescription: ""
    property string initialCode: ""

    property bool showAIModal: false
    property bool isAIFetching: false
    property string aiFullResponse: ""
    property string aiDisplayedResponse: ""
    property int aiTypeIndex: 0

    AIManager {
        id: aiManager

        onHintReceived: function (hint) {
            solvingPage.isAIFetching = false;
            solvingPage.aiFullResponse = hint;
            aiTypewriterTimer.start();
        }

        onRequestFailed: function (errorMessage) {
            solvingPage.isAIFetching = false;
            solvingPage.aiFullResponse = "⚠️ " + errorMessage;
            aiTypewriterTimer.start();
        }
    }

    // i didnt feel like it was worth it to write a whole manager object so I just coded it straight in
    // since were just making one post request then doing formatting
    function submitCode(isLaunchMode) {
        solvingPage.isEvaluating = true;
        solvingPage.isErrorState = false;
        solvingPage.errorOutput = "";
        solvingPage.stdOutput = "";
        solvingPage.displayedCases = 0;

        if (!isLaunchMode) {
            solvingPage.showResultsModal = true;
        }

        if (isLaunchMode) {
            launchButton.launchState = "evaluating";
        }

        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:8080/api/submit_code");
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;

            solvingPage.isEvaluating = false;

            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);

                    if (response.status === "error" && response.type !== "test_failure") {
                        solvingPage.isErrorState = true;
                        solvingPage.errorOutput = response.message;

                        if (isLaunchMode) {
                            launchButton.launchState = "failed";
                            solvingPage.showResultsModal = true;
                        }
                    } else {
                        var results = response.test_results;

                        solvingPage.totalCases = results.tests;
                        solvingPage.passedCases = results.tests - results.failures;

                        var timeInSeconds = parseFloat(results.time);

                        solvingPage.runtimeMs = (timeInSeconds * 1000).toFixed(2);

                        if (response.output !== undefined) {
                            solvingPage.stdOutput = response.output;
                        }

                        if (response.new_xp !== undefined && response.new_streak !== undefined) {
                            window.userxp = response.new_xp;
                            window.userstreak = response.new_streak;
                        }

                        if (isLaunchMode) {
                            launchButton.launchState = (solvingPage.passedCases === solvingPage.totalCases) ? "success" : "failed";

                            if (solvingPage.passedCases === solvingPage.totalCases) {
                                authManager.fetchProblemsList(solvingPage.language);

                                launchSuccessReturnTimer.start();
                            } else {
                                solvingPage.showResultsModal = true;
                            }
                        }

                        simulationTimer.start();
                    }
                } catch (e) {
                    solvingPage.isErrorState = true;
                    solvingPage.errorOutput = "Failed to parse server response.";

                    if (isLaunchMode) {
                        launchButton.launchState = "failed";
                        solvingPage.showResultsModal = true;
                    }
                }
            } else {
                solvingPage.isErrorState = true;

                var serverMsg = "Server Error: " + xhr.status;

                try {
                    serverMsg = JSON.parse(xhr.responseText).message;
                } catch (e) {}

                solvingPage.errorOutput = serverMsg;

                if (isLaunchMode) {
                    launchButton.launchState = "failed";
                    solvingPage.showResultsModal = true;
                }
            }

            if (isLaunchMode) {
                launchResetTimer.start();
            }
        };

        var payload = {
            "language": solvingPage.language,
            "code": myCodeEditor.text,
            "problem_id": solvingPage.problemId,
            "username": window.username,
            "is_launch": isLaunchMode
        };

        xhr.send(JSON.stringify(payload));
    }

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
            Layout.preferredHeight: 200
            Layout.maximumHeight: 250
            color: "#131E30"
            radius: 12
            clip: true

            ScrollView {
                id: descScroll
                anchors.fill: parent
                anchors.margins: 10
                padding: 15
                contentHeight: descriptionText.height + 40

                Text {
                    id: descriptionText
                    width: descScroll.availableWidth - 10
                    text: missionDescription.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\n/g, "<br>")
                    color: "#CBD5E1"
                    font.pixelSize: 16
                    wrapMode: Text.WordWrap
                    lineHeight: 1.4
                    height: implicitHeight
                }
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

            Button {
                id: askAIButton
                text: "✨ Ask AI"
                Layout.preferredWidth: 130
                Layout.preferredHeight: 44
                scale: pressed ? 0.95 : (hovered ? 1.03 : 1.0)
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    font.pixelSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 22
                    border.color: "#8B5CF6"
                    border.width: parent.hovered ? 2 : 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: parent.pressed ? "#5B21B6" : (parent.hovered ? "#7C3AED" : "#4C1D95")
                        }
                        GradientStop {
                            position: 1.0
                            color: parent.pressed ? "#1D4ED8" : (parent.hovered ? "#2563EB" : "#1E3A8A")
                        }
                    }
                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                onClicked: {
                    solvingPage.showAIModal = true;
                    solvingPage.isAIFetching = true;
                    solvingPage.aiDisplayedResponse = "";
                    solvingPage.aiFullResponse = "";
                    solvingPage.aiTypeIndex = 0;
                    aiTypewriterTimer.stop();
                    aiManager.fetchHint(solvingPage.missionDescription, myCodeEditor.text);
                }
            }

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
                onClicked: solvingPage.submitCode(false) // the bool here just distingushes between run and launch
            }

            Button {
                id: launchButton
                property string launchState: "idle"
                Layout.preferredWidth: (launchState === "success" || launchState === "failed") ? 44 : 150
                Layout.preferredHeight: 44
                enabled: launchState === "idle"

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutBack
                    }
                }

                contentItem: Item {
                    anchors.fill: parent
                    BusyIndicator {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        running: launchButton.launchState === "evaluating"
                        visible: launchButton.launchState === "evaluating"
                    }
                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (launchButton.launchState === "idle")
                                return "LAUNCH 🚀";
                            if (launchButton.launchState === "success")
                                return "✓";
                            if (launchButton.launchState === "failed")
                                return "✗";
                            return "";
                        }
                        color: "white"
                        font.bold: true
                        font.pixelSize: (launchButton.launchState === "success" || launchButton.launchState === "failed") ? 22 : 16
                        font.letterSpacing: launchButton.launchState === "idle" ? 1.5 : 0
                        visible: launchButton.launchState !== "evaluating"
                        Behavior on font.pixelSize {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }
                }

                background: Rectangle {
                    radius: (launchButton.launchState === "success" || launchButton.launchState === "failed") ? 22 : 8
                    color: {
                        if (launchButton.launchState === "evaluating")
                            return "#3B82F6";
                        if (launchButton.launchState === "success")
                            return "#10B981";
                        if (launchButton.launchState === "failed")
                            return "#EF4444";
                        return parent.pressed ? "#047857" : (parent.hovered ? "#059669" : "#10B981");
                    }
                    Behavior on radius {
                        NumberAnimation {
                            duration: 350
                            easing.type: Easing.OutBack
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                        }
                    }
                }

                onClicked: solvingPage.submitCode(true)
            }
        }
    }

    // send back to table if tests work
    Timer {
        id: launchSuccessReturnTimer
        interval: 1500
        onTriggered: {
            solvingPage.StackView.view.pop();
            solvingPage.StackView.view.pop();
        }
    }

    Timer {
        id: launchResetTimer
        interval: 3500
        onTriggered: {
            launchButton.launchState = "idle";
        }
    }

    Timer {
        id: simulationTimer
        interval: 100
        repeat: true
        onTriggered: {
            if (solvingPage.displayedCases < solvingPage.totalCases) {
                solvingPage.displayedCases++;
            } else {
                stop();
            }
        }
    }

    Timer {
        id: aiTypewriterTimer
        interval: 25
        repeat: true
        onTriggered: {
            if (solvingPage.aiTypeIndex < solvingPage.aiFullResponse.length) {
                solvingPage.aiDisplayedResponse += solvingPage.aiFullResponse[solvingPage.aiTypeIndex];
                solvingPage.aiTypeIndex++;
            } else {
                stop();
            }
        }
    }

    // ai assistant
    Rectangle {
        id: aiOverlay
        anchors.fill: parent
        color: Qt.rgba(0.03, 0.04, 0.08, 0.85)
        z: 99

        opacity: solvingPage.showAIModal ? 1.0 : 0.0
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: solvingPage.showAIModal = false
        }

        Rectangle {
            id: aiModalView
            width: 600
            height: 480
            anchors.centerIn: parent
            color: "#0B1120"
            radius: 20
            border.color: "#1E293B"
            border.width: 1

            scale: solvingPage.showAIModal ? 1.0 : 0.95
            Behavior on scale {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
            }

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32
                spacing: 24

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: solvingPage.isAIFetching ? "#8B5CF6" : "#38BDF8"
                        Behavior on color {
                            ColorAnimation {
                                duration: 400
                            }
                        }
                    }

                    Text {
                        text: "AI Assistant"
                        color: "#F8FAFC"
                        font.pixelSize: 20
                        font.bold: true
                        font.letterSpacing: 0.5
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#1E293B"
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: solvingPage.isAIFetching
                        visible: solvingPage.isAIFetching
                    }

                    ScrollView {
                        id: aiTextScroll
                        anchors.fill: parent
                        clip: true
                        visible: !solvingPage.isAIFetching
                        contentWidth: availableWidth
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        Text {
                            width: aiTextScroll.availableWidth
                            text: solvingPage.aiDisplayedResponse
                            color: "#CBD5E1"
                            font.pixelSize: 16
                            wrapMode: Text.WordWrap
                            lineHeight: 1.6
                        }
                    }
                }

                Button {
                    text: "Got it"
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 44

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        font.pixelSize: 15
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#2563EB" : (parent.hovered ? "#3B82F6" : "#1D4ED8")
                        radius: 22
                    }
                    onClicked: {
                        solvingPage.showAIModal = false;
                    }
                }
            }
        }
    }

    // tests modal
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
            width: 550
            height: (solvingPage.isErrorState || solvingPage.stdOutput !== "") ? 600 : 420
            anchors.centerIn: parent
            color: "#0F172A"
            radius: 16
            border.color: solvingPage.isEvaluating ? "#334155" : (solvingPage.isErrorState ? "#991B1B" : (passedCases === totalCases ? "#059669" : "#B45309"))
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
                spacing: 16

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10
                    Text {
                        text: solvingPage.isEvaluating ? "Evaluating..." : (solvingPage.isErrorState ? "Execution Failed" : (passedCases === totalCases ? "Mission Accomplished" : "Partial Success"))

                        color: solvingPage.isEvaluating ? "#60A5FA" : (solvingPage.isErrorState ? "#EF4444" : (passedCases === totalCases ? "#34D399" : "#F59E0B"))
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

                // animation to show the tests failed and passed
                GridLayout {
                    visible: !solvingPage.isErrorState
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

                Rectangle {
                    visible: !solvingPage.isErrorState
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
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
                                text: solvingPage.runtimeMs + " ms"
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                            }
                        }
                    }
                }

                // output terminal
                Rectangle {
                    visible: !solvingPage.isEvaluating && (solvingPage.isErrorState || solvingPage.stdOutput !== "")
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#0B1120"
                    radius: 8
                    border.color: solvingPage.isErrorState ? "#7F1D1D" : "#334155"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: solvingPage.isErrorState ? "#450A0A" : "#1E293B"
                            radius: 8

                            Rectangle {
                                width: parent.width
                                height: 10
                                anchors.bottom: parent.bottom
                                color: parent.color
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                text: solvingPage.isErrorState ? "CRASH LOG" : "STANDARD OUTPUT"
                                color: "#94A3B8"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 1
                            }
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            Text {
                                width: parent.width
                                padding: 15
                                text: solvingPage.isErrorState ? solvingPage.errorOutput : solvingPage.stdOutput
                                color: solvingPage.isErrorState ? "#FCA5A5" : "#CBD5E1"
                                font.family: "Monospace"
                                font.pixelSize: 13
                                wrapMode: Text.Wrap
                                lineHeight: 1.2
                            }
                        }
                    }
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
