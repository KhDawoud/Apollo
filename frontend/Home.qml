import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Rectangle {
    id: homeRoot
    signal goToProblems()
    signal goToLeaderboard()
    signal goToMatchFinder()
    signal goToProgress()
    color: "#000015"
    anchors.fill: parent
    property int selectedIndex: -1

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

    ListModel {
        id: languageModel
        ListElement { iconPath: "images/laptop.png"; name: "Problems"; description: "Tackle curated challenges across 8 langauges, ranked by difficulty.";}
        ListElement { iconPath: "images/trophy.png"; name: "Leaderboard"; description: "See where you stand globally. Compete climb, and claim the top spot.";}
        ListElement { iconPath: "images/matchmaking.png"; name: "MatchFinder"; description: "Get matched with rivals at your level for real-time coding battles.";}
        ListElement { iconPath: "images/progress_graph.png"; name: "Progress";description: "Track your score, problems solved, and language mastery over time.";}
    }
    ScrollView {
           anchors.fill: parent
           contentWidth: -1
            contentHeight: mainColumn.implicitHeight
           ScrollBar.vertical.policy: ScrollBar.AlwaysOn
           Item { width: 1; height: 15 }

           Column {
               id: mainColumn
               width: homeRoot.width
               spacing: 0

               Item { width: 1; height: 50 }      // gap at top
               Text {
                   id: titleText1
                   text: qsTr("Learn to Code.")
                   anchors.horizontalCenter: parent.horizontalCenter
                   font.bold: true
                   font.pointSize: 52
                   color: "white"
                   font.letterSpacing: 2
               }

               Item { width: 1; height: 20 }      // gap between titles
               Text {
                   id: titleText2
                   text: qsTr("Level Up.")
                   anchors.horizontalCenter: parent.horizontalCenter
                   font.bold: true
                   font.pointSize: 52
                   color: "#3F72AF"
                   font.letterSpacing: 2
               }

               Item { width: 1; height: 15 }
               Text {
                   id: subHeading
                   text: qsTr("The gamified coding platform built for the next generation of programmers")
                   anchors.horizontalCenter: parent.horizontalCenter
                   font.pointSize: 16
                   color: "#8A9BB5"
                   font.letterSpacing: 2
               }

               Item { width: 1; height: 60 }
               Button {
                   id: startMissionBtn
                   anchors.horizontalCenter: parent.horizontalCenter
                   width: 425
                   height: 75
                   enabled: true
                   hoverEnabled: true

                   contentItem: Row {
                       anchors.centerIn: parent
                       spacing: 12

                       Text {
                           text: qsTr("START YOUR MISSION")
                           color: startMissionBtn.hovered ? "white" : "transparent"
                           font.pointSize: 17
                           font.letterSpacing: 2
                           font.bold:true
                           //anchors.horizontalCenter: parent.horizontalCenter
                           anchors.verticalCenter: parent.verticalCenter
                           anchors.left: parent.left
                           anchors.leftMargin: 27

                           Behavior on color { ColorAnimation { duration: 150 } }
                       }

                       AnimatedImage {
                           source: "images/rocket.gif"
                           width: 62
                           height: 62
                           fillMode: Image.PreserveAspectFit
                           anchors.right: parent.right
                           anchors.verticalCenter: parent.verticalCenter
                           Behavior on opacity { NumberAnimation { duration: 150 } }
                       }
                   }

                   background: Rectangle {
                       radius: 10
                       color: startMissionBtn.pressed ? "#c23a13" : (startMissionBtn.hovered ? "#E25822" : "transparent")
                       border.color: "black"
                       border.width: 2
                       Behavior on color { ColorAnimation { duration: 150 } }

                       Rectangle {
                           id: pulseRing
                           anchors.centerIn: parent
                           width: parent.width
                           height: parent.height
                           radius: parent.radius
                           color: "transparent"
                           border.color: "#3F72AF"
                           border.width: 2

                           SequentialAnimation {
                               running: true
                               loops: Animation.Infinite

                               ParallelAnimation {
                                   NumberAnimation {
                                       target: pulseRing
                                       property: "scale"
                                       from: 1.0
                                       to: 1.15
                                       duration: 1750
                                       easing.type: Easing.OutQuad
                                   }
                                   NumberAnimation {
                                       target: pulseRing
                                       property: "opacity"
                                       from: 0.3
                                       to: 0.0
                                       duration: 1750
                                       easing.type: Easing.OutQuad
                                   }
                               }

                               PauseAnimation { duration: 750 }
                           }
                       }
                   }

                   onClicked: homeRoot.goToProblems()
               }

               Item { width: 1; height: 100 }
               RowLayout {
                   id: statsRow
                   anchors.horizontalCenter: parent.horizontalCenter
                   spacing: 0
                   Repeater {
                       model: [
                           { num: "8",    label: "LANGUAGES"    },
                           { num: "100+", label: "PROBLEMS"      },
                           { num: "2.4k", label: "PILOTS RANKED" }
                       ]
                       delegate: RowLayout {
                           spacing: 0
                           Rectangle {
                               visible: index !== 0
                               width: 1
                               height: 100
                               color: "#1E3A5A"
                           }
                           Column {
                               spacing: 6
                               leftPadding: 40
                               rightPadding: 40
                               Text {
                                   text: modelData.num
                                   font.pointSize: 44
                                   font.bold: true
                                   color: "white"
                                   anchors.horizontalCenter: parent.horizontalCenter
                               }
                               Text {
                                   text: modelData.label
                                   font.pointSize: 16
                                   color: "#5A7A9A"
                                   font.letterSpacing: 1.5
                                   anchors.horizontalCenter: parent.horizontalCenter
                               }
                           }
                       }
                   }
               }

               Item { width: 1; height: 100 }
               Text {
                   id: titleText3
                   text: qsTr("FEATURES")
                   anchors.horizontalCenter: parent.horizontalCenter
                   font.bold: true
                   font.pointSize: 16
                   color: "#5A7A9A"
                   font.letterSpacing: 2
               }

               Item { width: 1; height: 30 }
               Text {
                   id: titleText4
                   text: qsTr("EVERYTHING YOU NEED TO LAUNCH")
                   anchors.horizontalCenter: titleText3.horizontalCenter
                   font.bold: true
                   font.pointSize: 30
                   color: "white"
                   font.letterSpacing: 2
               }

               Item { width: 1; height: 50 }
               GridView {
                   id: languageGrid
                   anchors.horizontalCenter: parent.horizontalCenter
                   width: cellWidth * 4
                   height: cellHeight * 1
                   cellWidth: 300
                   cellHeight: 400
                   clip: true
                   model: languageModel
                   delegate: Item {
                       width: languageGrid.cellWidth
                       height: languageGrid.cellHeight
                       Rectangle {
                           id: card
                           anchors.centerIn: parent
                           width: 260
                           height: 360
                           //color: homeRoot.selectedIndex === index ? "#112D4E" : "#112D4E"
                           color: "#112D4E"
                           radius: 15
                           //border.width: homeRoot.selectedIndex === index ? 3 : 1
                           border.width: cardMouseArea.containsMouse ? 3 : 1
                           //border.color: homeRoot.selectedIndex === index ? "#BEE3F8" : "#335b8c"
                           border.color: cardMouseArea.containsMouse ? "#BEE3F8" : "#335b8c"
                           Behavior on color { ColorAnimation { duration: 150 } }
                           Column {
                               anchors.top: parent.top
                                anchors.topMargin: 30        // gap from top of card
                                anchors.horizontalCenter: parent.horizontalCenter
                               spacing: 15
                               Image {
                                   source: iconPath
                                   width: 80
                                   height: 80
                                   anchors.horizontalCenter: parent.horizontalCenter
                                   fillMode: Image.PreserveAspectFit
                               }
                               Text {
                                   text: name
                                   color: "white"
                                   font.pointSize: 17
                                   font.bold: true
                                   anchors.horizontalCenter: parent.horizontalCenter
                               }
                               Text {
                                   text: description
                                   color: "#5A7A9A"
                                   font.pointSize: 13
                                   font.bold: true
                                   width: 200
                                   wrapMode: Text.WordWrap
                                   horizontalAlignment: Text.AlignHCenter
                               }
                           }
                           MouseArea {
                               id: cardMouseArea
                               anchors.fill: parent
                               hoverEnabled: true
                               onClicked: {
                                   //homeRoot.selectedIndex = index
                                   if (index === 0) homeRoot.goToProblems()  // then navigate based on which card it was
                                       else if (index === 1) homeRoot.goToLeaderboard()
                                       else if (index === 2) homeRoot.goToMatchFinder()
                                       else if (index === 3) homeRoot.goToProgress()}
                               onEntered: card.scale = 1.05
                               onExited: card.scale = 1.0
                           }
                           Behavior on scale { NumberAnimation { duration: 100 } }
                           Behavior on border.color { ColorAnimation { duration: 150 } }
                       }
                   }
               }

               Item { width: 1; height: 60 }  // bottom padding
           }
    }
}
