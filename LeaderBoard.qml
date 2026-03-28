import QtQuick
import QtQuick.Controls

Rectangle {
    id: rect
    color: "#000015"
    anchors.fill: parent

    Item {
        id: starfield
        anchors.fill: parent

        Repeater {
            model: 150
            Rectangle {
                property int animDuration: Math.random() * 5000 + 1000

                x: Math.random() * starfield.width
                y: Math.random() * starfield.height
                width: Math.random() * 3 + 1
                height: width
                radius: width / 2
                color: "#D7D7D7"

                opacity: Math.random()

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: true

                    NumberAnimation {
                        to: 1.0
                        duration: animDuration
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        to: 0.1
                        duration: animDuration
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }

    Text {
        id: titleText
        text: "LEADERBOARD"
        anchors.top: parent.top
        anchors.topMargin: 40
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
        anchors.bottomMargin: 40

        color: "#112D4E"
        radius: 20
        border.color: "#3F72AF"
        border.width: 2

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8
            clip: true
            model: 10

            delegate: ItemDelegate {
                width: list.width
                height: 40

                background: Rectangle {
                    color: "#3F72AF"
                    radius: 10
                    border.color: "#DBE2EF"
                }

                contentItem: Text {
                    text: (index + 1) + "    Player " + (index + 1)

                    color: {
                        if (index === 0) return "#C9B037"
                        else if (index === 1) return "#D7D7D7"
                        else if (index === 2) return "#CE8946"
                        else return "black"
                    }

                    font.pointSize: 14
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 20
                }
            }
        }
    }
}
