import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: problemsPage
    color: "transparent"
    anchors.fill: parent

    property string language: "Unknown"
    property string currentFilter: "All"

    // --- DATA MODELS ---
    ListModel {
        id: filterModel
        ListElement { name: "All" }
        ListElement { name: "Arrays" }
        ListElement { name: "Strings" }
        ListElement { name: "Math" }
        ListElement { name: "Logic" }
    }

    ListModel {
        id: problemsModel
        ListElement { name: "Two Sum Target"; topic: "Arrays"; difficulty: "Easy"; diffColor: "#10B981" }
        ListElement { name: "Reverse Substring"; topic: "Strings"; difficulty: "Medium"; diffColor: "#F59E0B" }
        ListElement { name: "Matrix Traversal"; topic: "Logic"; difficulty: "Hard"; diffColor: "#EF4444" }
        ListElement { name: "Prime Factorization"; topic: "Math"; difficulty: "Medium"; diffColor: "#F59E0B" }
        ListElement { name: "Anagram Checker"; topic: "Strings"; difficulty: "Easy"; diffColor: "#10B981" }
    }


    RowLayout {
        id: headerRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20

        Button {
            text: "← Back"
            onClicked: problemsPage.StackView.view.pop()
            background: Rectangle { color: "transparent" }
            contentItem: Text {
                text: parent.text
                color: "#94A3B8"
                font.pointSize: 14
                font.bold: true
            }
        }

        Text {
            Layout.fillWidth: true
            text: qsTr("MISSIONS: ") + language.toUpperCase()
            color: "white"
            font.pointSize: 20
            font.bold: true
            horizontalAlignment: Text.AlignRight
            font.letterSpacing: 1
        }
    }

    ListView {
        id: filterList
        anchors.top: headerRow.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 40
        height: 40
        orientation: ListView.Horizontal
        spacing: 15
        model: filterModel
        clip: true

        delegate: Button {
            width: implicitWidth
            height: 35
            contentItem: Text {
                text: model.name
                color: problemsPage.currentFilter === model.name ? "white" : "#94A3B8"
                font.pointSize: 12
                font.bold: true
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 17.5
                color: problemsPage.currentFilter === model.name ? "#3B82F6" : "#1E293B"
                border.color: problemsPage.currentFilter === model.name ? "#60A5FA" : "#334155"
            }
            onClicked: problemsPage.currentFilter = model.name
        }
    }

    Rectangle {
        id: tableContainer
        anchors.top: filterList.bottom
        anchors.topMargin: 30
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        anchors.bottomMargin: 30

        color: "#131E30"
        radius: 12
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                id: tableHeader
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#1E293B"
                radius: 12

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.radius
                    color: parent.color
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    z: 1

                    Text {
                        Layout.fillWidth: true
                        text: "MISSION NAME"
                        color: "#94A3B8"; font.bold: true; font.pointSize: 11
                    }
                    Text {
                        Layout.preferredWidth: 120
                        text: "TOPIC"
                        color: "#94A3B8"; font.bold: true; font.pointSize: 11
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        Layout.preferredWidth: 100
                        text: "DIFFICULTY"
                        color: "#94A3B8"; font.bold: true; font.pointSize: 11
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#334155"
                    z: 2
                }
            }

            ListView {
                id: tableBody
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 0
                model: problemsModel

                delegate: Rectangle {
                    id: rowDelegate
                    width: tableBody.width

                    visible: problemsPage.currentFilter === "All" || problemsPage.currentFilter === model.topic
                    height: visible ? 60 : 0

                    color: mouseArea.containsMouse ? "#1E293B" : "transparent"

                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 20

                        Text {
                            Layout.fillWidth: true
                            text: model.name
                            color: "white"; font.pointSize: 13; font.bold: true
                        }

                        Item {
                            Layout.preferredWidth: 120
                            height: 28
                            Rectangle {
                                anchors.centerIn: parent
                                width: 100; height: 24
                                color: "transparent"; border.color: "#334155"
                                border.width: 1; radius: 12
                                Text {
                                    anchors.centerIn: parent; text: model.topic
                                    color: "#CBD5E1"; font.pointSize: 10
                                }
                            }
                        }

                        Text {
                            Layout.preferredWidth: 100
                            text: model.difficulty
                            color: model.diffColor
                            font.pointSize: 12; font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    // Separator
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#334155"
                        visible: rowDelegate.visible // Only if row is shown
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: console.log("Selected Problem: " + model.name)
                    }
                }
            }
        }
    }
}
