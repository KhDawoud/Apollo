import QtQuick
import QtQuick.Controls

Rectangle {
    id: rect
    color: "#112D4E"
    anchors.fill: parent
    Text{
        text: "LEADERBOARD"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -300
        anchors.horizontalCenterOffset: -10
        font.bold: true
        font.pointSize: 40
        color: "#3F72AF"

    }
    Rectangle{
        id: listbackground
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 50
        width:parent.width*0.85
        height:510
        color: "#112D4E"
        radius: 20                 // Curved corners for the container
        border.color: "#3F72AF"
        border.width: 2

        ListView {
            id:list
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8
            clip: true
            model: 10 //10 rows

            delegate: ItemDelegate {
                width: list.width
                height: 40
                background: Rectangle {
                    color: "#3F72AF"
                    radius: 10 // This makes each row curved
                    border.color: "#DBE2EF"
                }
                contentItem: Text {
                    text: (index + 1) + "    Player " + (index + 1)
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 20
                }
            }

        }
    }
}
