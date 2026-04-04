import QtQuick
import QtQuick.Controls

Item {
    id: problemsContainer

    StackView {
        id: problemsStack
        anchors.fill: parent

        initialItem: Component {
            LanguageSelect {

                onLanguageChosen: function(langName) {
                    problemsStack.push("ProblemTable.qml", { "language": langName })
                }

            }
        }
    }
}
