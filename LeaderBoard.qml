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
        color: "white"

    }
    Item {
            id: starfield
            anchors.fill: parent

            Repeater {
                model: 100 // Number of stars
                Rectangle {
                    // Random position and size
                    x: Math.random() * starfield.width
                    y: Math.random() * starfield.height
                    width: Math.random() * 3 + 1
                    height: width
                    radius: width / 2
                    color: "#D7D7D7"

                    // Twinkling effect
                    opacity: Math.random()
                    NumberAnimation on opacity {
                        from: 0.1; to: 2.0; duration: Math.random() * 5000 + 1000
                        loops: Animation.Infinite; running: true
                    }
                }
        }
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
                    text:
                        if(index+1==1){
                            (index + 1) + "    Player " + (index + 1)
                        }else if(index+1==2){
                            (index + 1) + "    Player " + (index + 1)
                        }else if(index+1==3){
                            (index + 1) + "    Player " + (index + 1)
                        }else{
                            (index + 1) + "    Player " + (index + 1)
                        }
                    color:{
                        if(index+1==1){
                            color: "#C9B037"
                        }else if(index+1==2){
                            color: "#D7D7D7"
                        }else if(index+1==3){
                            color: "#CE8946"
                        }else{
                            color: "black"
                        }
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
