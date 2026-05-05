import QtQuick
import QtQuick.Controls
Item {
    id: matchmakingContainer
    StackView {
        id: mainStack
        anchors.fill: parent

        initialItem: MatchmakingTable {
            onMissionStarted: (langIdx, diff) => {
                mainStack.push("MatchLoading.qml", {
                    "gameLanguage": langIdx,
                    "gameDifficulty": diff,
                    "username" : username,
                    "userxp": userxp,
                    "userstreak": userstreak
                })
            }
        }

        pushEnter: Transition {
            PropertyAnimation { property: "x"; from: mainStack.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
        }
        pushExit: Transition {
            PropertyAnimation { property: "x"; from: 0; to: -mainStack.width; duration: 400; easing.type: Easing.OutCubic }
        }
    }
}

