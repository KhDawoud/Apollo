#include "CodeEditor.h"

CodeEditor::CodeEditor(QWidget *parent)
    : QsciScintilla(parent)
{
    auto *lexer = new QsciLexerJavaScript(this);
    setLexer(lexer);

    setUtf8(true);
    setMarginType(0, QsciScintilla::NumberMargin);
    setMarginWidth(0, "0000");

    setBraceMatching(QsciScintilla::SloppyBraceMatch);

    setCaretLineVisible(true);
    setCaretLineBackgroundColor(QColor("#1E293B"));

    setPaper(QColor("#0B1120"));
    setColor(QColor("#E2E8F0"));

    setFont(QFont("Courier", 12));
}
