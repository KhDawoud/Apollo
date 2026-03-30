import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Rectangle {
    id: rect
    color: "transparent"

    Text {
        id: titleText
        text: "LEADERBOARD"
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.08
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        font.pointSize: 40
        color: "white"
    }


    Rectangle {
        id: listbackground
        anchors.top: titleText.bottom
        anchors.topMargin: 30 //
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.85

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60

        color: "#112D4E"
        radius: 20
        border.color: "#3F72AF"
        border.width: 2

        // --- Column Headers ---
        RowLayout {
            id: headerRow
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 15
            anchors.leftMargin: 35
            anchors.rightMargin: 35
            spacing: 40
            height: 10

            Text {
                text: "RANK"
                font.bold: true
                font.pointSize: 10
                color: "#DBE2EF"
                Layout.preferredWidth: 30
            }

            Text {
                text: "PLAYER NAME"
                font.bold: true
                font.pointSize: 10
                color: "#DBE2EF"

                Layout.fillWidth: true
            }

            Text {
                text: "SCORE"
                font.bold: true
                font.pointSize: 10
                color: "#DBE2EF"
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 100
            }
        }


        ListView {
            id:list
            anchors.top: headerRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 15
            spacing: 8
            clip: true
            model: ListModel {
                ListElement { name: "Player 1"; score: "25,400" }
                ListElement { name: "Player 2"; score: "22,100" }
                ListElement { name: "Player 3"; score: "19,850" }
                ListElement { name: "Player 4"; score: "15,200" }
                ListElement { name: "Player 5"; score: "14,900" }
                ListElement { name: "Player 6"; score: "13,900" }
                ListElement { name: "Player 7"; score: "11,300" }
                ListElement { name: "Player 8"; score: "10,100" }
                ListElement { name: "Player 9"; score: "9,900" }
                ListElement { name: "Player 10"; score: "9,200" }
            }

            delegate: ItemDelegate {
                width: list.width
                height: 40
                background: Rectangle {
                    color: "#3F72AF"
                    radius: 10 // This makes each row curved
                    border.color: "#DBE2EF"
                }
                contentItem: RowLayout{
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 40
                    Item {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30

                        Image {
                            anchors.centerIn: parent
                            width: 60
                            height: 60
                            fillMode: Image.PreserveAspectFit
                            // Show images for index 0, 1, 2
                            visible: index <= 2
                            source: {
                                if (index === 0) return "images/1st.png";
                                if (index === 1) return "images/2nd.png";
                                if (index === 2) return "images/3rd.png";
                                return "";
                            }
                        }

                        Text { //Rank
                            anchors.centerIn: parent
                            // Show number only for index 3 and above
                            visible: index > 2
                            text: index + 1
                            color: "white"
                            font.pointSize: 14
                            font.bold: true
                        }
                }
                    Text{ //Name
                        text: name
                        color:{
                            if(index+1==1)
                                return "#C9B037"
                            if(index+1==2)
                                return "#D7D7D7"
                            if(index+1==3)
                                return "#CE8946"
                            return "white"
                        }
                        font.pointSize: 14
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    Text { //Score
                        text: score // Pulls from ListElement
                        font.bold: true
                        font.pointSize: 14
                        color: "#BEE3F8" // Light blue for scores
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
