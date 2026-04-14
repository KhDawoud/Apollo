import QtQuick
import QtQuick.Controls

Item {
    id: problemsContainer
    // all the problems pages are just one stackview which pushes on top of one another
    StackView {
        id: problemsStack
        anchors.fill: parent

        initialItem: Component {
            LanguageSelect {

                onLanguageChosen: function (langName) {
                    problemsStack.push("ProblemTable.qml", {
                        "language": langName
                    });
                }
            }
        }
    }
}
