//Mission SOlver
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Apollo.Code
import Apollo.Backend 1.0

Rectangle {
    id: solvingPage
    color: "transparent"

    property bool showResultsModal: false
    property int displayedCases: 0
    property bool isEvaluating: false

    property int totalCases: 12
    property int passedCases: 7

    property string language: "Unknown"
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
                        .replace(/&/g, "&amp;")
                        .replace(/</g, "&lt;")
                        .replace(/>/g, "&gt;")
                        .replace(/\n/g, "<br>")
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

                onClicked: {
                    solvingPage.displayedCases = 0;
                    solvingPage.isEvaluating = true;
                    solvingPage.showResultsModal = true;
                    simulationTimer.start();
                }
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

                onClicked: {
                    launchButton.launchState = "evaluating";

                    // ill connect the testing logic here once we fix the problems

                    launchMockTimer.start();
                }
            }
        }
    }

    // timers for animations

    // will remove after i connect tests backend for now it just randomly fails or passes
    Timer {
        id: launchMockTimer
        interval: 1500 
        onTriggered: {
            var passed = Math.random() > 0.5;
            launchButton.launchState = passed ? "success" : "failed";
            launchResetTimer.start();
        }
    }

    Timer {
        id: launchResetTimer
        interval: 2500
        onTriggered: {
            launchButton.launchState = "idle";
        }
    }

    // simulates the tests occuring
    Timer {
        id: simulationTimer
        interval: 100
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

    // simulates ai typing out response
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

    // the popups

    //ai
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

    // tests
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
