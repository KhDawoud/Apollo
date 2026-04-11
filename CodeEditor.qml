import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#1E1E1E"
    radius: 12
    border.color: "#333333"
    clip: true

    property alias text: editor.text
    property alias textDocument: editor.textDocument
    property int fontSize: 15
    property string fontColor: "#D4D4D4"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Line Numbers
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 45
            color: "#252526"

            Flickable {
                anchors.fill: parent
                contentY: editorScrollView.contentItem.contentY
                interactive: false
                clip: true

                Column {
                    anchors.fill: parent
                    topPadding: editor.topPadding

                    Repeater {
                        model: editor.lineCount
                        delegate: Text {
                            width: 45
                            height: editor.contentHeight / editor.lineCount
                            text: index + 1
                            // Muted gray for line numbers
                            color: "#858585"
                            font.family: "monospace"
                            font.pixelSize: root.fontSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            Rectangle {
                anchors.right: parent.right
                height: parent.height
                width: 1
                color: "#333333"
            }
        }

        ScrollView {
            id: editorScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            TextArea {
                id: editor
                color: root.fontColor
                font.family: "monospace"
                font.pixelSize: root.fontSize
                background: null
                selectByMouse: true
                wrapMode: TextEdit.NoWrap
                leftPadding: 16
                topPadding: 16
                rightPadding: 16
                bottomPadding: 16
                tabStopDistance: font.pixelSize * 4

                // Smart Indentation & Auto-Closing Logic
                Keys.onPressed: (event) => {
                    let cursor = editor.cursorPosition

                    // Auto-close Quotes
                    if (event.text === '"') {
                        editor.insert(cursor, "\"\"")
                        editor.cursorPosition = cursor + 1
                        event.accepted = true
                    }
                    // Auto-close Parentheses
                    else if (event.text === '(') {
                        editor.insert(cursor, "()")
                        editor.cursorPosition = cursor + 1
                        event.accepted = true
                    }
                    // Auto-close Braces
                    else if (event.text === '{') {
                        editor.insert(cursor, "{}")
                        editor.cursorPosition = cursor + 1
                        event.accepted = true
                    }
                    // Tab Trapping
                    else if (event.key === Qt.Key_Tab) {
                        editor.insert(cursor, "    ")
                        event.accepted = true
                    }
                    // Smart Enter / Return
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        let textUpToCursor = editor.text.substring(0, cursor)
                        let lastNewline = textUpToCursor.lastIndexOf('\n')
                        let currentLine = textUpToCursor.substring(lastNewline + 1)

                        let indentMatch = currentLine.match(/^\s*/)
                        let baseIndent = indentMatch ? indentMatch[0] : ""

                        let nextChar = editor.text.substring(cursor, cursor + 1)

                        if (currentLine.trim().endsWith('{')) {
                            let extraIndent = baseIndent + "    "

                            // If pressing enter between { and }
                            if (nextChar === '}') {
                                editor.insert(cursor, "\n" + extraIndent + "\n" + baseIndent)
                                editor.cursorPosition = cursor + 1 + extraIndent.length
                            } else {
                                editor.insert(cursor, "\n" + extraIndent)
                            }
                        } else {
                            editor.insert(cursor, "\n" + baseIndent)
                        }
                        event.accepted = true
                    }
                }
            }
        }
    }
}
