#ifndef HIGHLIGHTER_H
#define HIGHLIGHTER_H

#pragma once
#include <QObject>
#include <QSyntaxHighlighter>
#include <QRegularExpression>
#include <QTextCharFormat>
#include <QQuickTextDocument>
#include <QMap>

// this builds on the syntaxhighlighter already in Qt to add support for other languages

// A lot of the implementation logic was heavily aided with AI since it requires lots of advanced
// regex and getting keywords words for 8 different language so I wouldn't have time to learn all of it.

class AdvancedHighlighter : public QSyntaxHighlighter {
public:
    AdvancedHighlighter(const QString &language, QTextDocument *parent = nullptr)
        : QSyntaxHighlighter(parent), m_language(language.toLower()) {
        setupFormats();
        setupRules();
    }

    void setActiveWord(const QString &word) {
        m_activeWord = word;
    }

protected:
    void highlightBlock(const QString &text) override {
        // 1. Standard Syntax Highlighting
        for (const HighlightingRule &rule : std::as_const(highlightingRules)) {
            QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
            while (matchIterator.hasNext()) {
                QRegularExpressionMatch match = matchIterator.next();
                setFormat(match.capturedStart(), match.capturedLength(), rule.format);
            }
        }

        // 2. Same-Word Selection Highlighting
        if (!m_activeWord.isEmpty()) {
            QRegularExpression wordRegex("\\b" + QRegularExpression::escape(m_activeWord) + "\\b");
            QRegularExpressionMatchIterator matchIterator = wordRegex.globalMatch(text);
            QTextCharFormat selectionFormat;
            selectionFormat.setBackground(QColor("#3A3D41"));

            while (matchIterator.hasNext()) {
                QRegularExpressionMatch match = matchIterator.next();
                QTextCharFormat currentFormat = format(match.capturedStart());
                currentFormat.setBackground(selectionFormat.background());
                setFormat(match.capturedStart(), match.capturedLength(), currentFormat);
            }
        }

        // 3. Multi-line comments (/* ... */)
        if (supportsMultiLineComments) {
            setCurrentBlockState(0);
            int startIndex = 0;
            if (previousBlockState() != 1) startIndex = text.indexOf(commentStartExpression);
            while (startIndex >= 0) {
                QRegularExpressionMatch match = commentEndExpression.match(text, startIndex);
                int endIndex = match.capturedStart();
                int commentLength = (endIndex == -1) ? text.length() - startIndex : endIndex - startIndex + match.capturedLength();
                if (endIndex == -1) setCurrentBlockState(1);
                setFormat(startIndex, commentLength, formatMap["Comment"]);
                startIndex = text.indexOf(commentStartExpression, startIndex + commentLength);
            }
        }
    }

private:
    QString m_language;
    QString m_activeWord;
    bool supportsMultiLineComments = false;

    struct HighlightingRule {
        QRegularExpression pattern;
        QTextCharFormat format;
    };
    QList<HighlightingRule> highlightingRules;
    QMap<QString, QTextCharFormat> formatMap;

    QRegularExpression commentStartExpression = QRegularExpression("/\\*");
    QRegularExpression commentEndExpression = QRegularExpression("\\*/");

    void addRule(const QString &pattern, const QString &formatName) {
        HighlightingRule rule;
        rule.pattern = QRegularExpression(pattern);
        rule.format = formatMap[formatName];
        highlightingRules.append(rule);
    }

    void setupFormats() {
        formatMap["Keyword"].setForeground(QColor("#C586C0"));
        formatMap["Type"].setForeground(QColor("#569CD6"));
        formatMap["Class"].setForeground(QColor("#4EC9B0"));
        formatMap["Function"].setForeground(QColor("#DCDCAA"));
        formatMap["Number"].setForeground(QColor("#B5CEA8"));
        formatMap["String"].setForeground(QColor("#CE9178"));
        formatMap["Comment"].setForeground(QColor("#6A9955"));
        formatMap["Annotation"].setForeground(QColor("#9B9B9B"));
        formatMap["Operator"].setForeground(QColor("#D4D4D4"));
    }

    void setupRules() {
        // Universal Rules
        addRule("[\\+\\-\\*\\/\\=\\<\\>\\!\\&\\|\\^\\%\\~\\?]", "Operator");
        addRule("\\b0[xX][0-9a-fA-F]+\\b", "Number");
        addRule("\\b0[bB][01]+\\b", "Number");
        addRule("\\b\\d+(\\.\\d+)?([eE][+-]?\\d+)?\\b", "Number");
        addRule("\\b[A-Z][a-zA-Z0-9_]*\\b", "Class");
        addRule("\\b([A-Za-z0-9_]+)(?=\\s*\\()", "Function");

        // Language Specific Rules
        if (m_language == "python" || m_language == "ruby") {
            supportsMultiLineComments = false;
            addRule("r?\"([^\"\\\\]|\\\\.)*\"", "String");
            addRule("r?'([^'\\\\]|\\\\.)*'", "String");
            addRule("#[^\n]*", "Comment");

            if (m_language == "python") {
                QStringList keywords = {"def", "import", "from", "as", "pass", "yield", "return", "if", "else", "elif", "for", "while", "try", "except", "finally", "with", "class", "global", "nonlocal", "lambda"};
                for (const QString &k : keywords) addRule("\\b" + k + "\\b", "Keyword");
                QStringList types = {"True", "False", "None", "self"};
                for (const QString &t : types) addRule("\\b" + t + "\\b", "Type");
            } else if (m_language == "ruby") {
                QStringList keywords = {"def", "require", "end", "unless", "return", "if", "else", "elsif", "for", "while", "do", "yield", "module", "class"};
                for (const QString &k : keywords) addRule("\\b" + k + "\\b", "Keyword");
                QStringList types = {"true", "false", "nil", "self"};
                for (const QString &t : types) addRule("\\b" + t + "\\b", "Type");
            }
        } else {
            supportsMultiLineComments = true;
            addRule("\"([^\"\\\\]|\\\\.)*\"", "String");
            addRule("'([^'\\\\]|\\\\.)*'", "String");
            if (m_language == "javascript" || m_language == "go") addRule("`([^`\\\\]|\\\\.)*`", "String");
            addRule("//[^\n]*", "Comment");

            QStringList types = {"int", "float", "double", "char", "bool", "boolean", "void", "string", "String", "true", "false", "null", "this"};
            for (const QString &t : types) addRule("\\b" + t + "\\b", "Type");

            QStringList keywords = {"return", "if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue", "try", "catch", "finally", "throw", "class", "struct", "enum", "interface"};
            for (const QString &k : keywords) addRule("\\b" + k + "\\b", "Keyword");

            if (m_language == "cpp") {
                addRule("#\\s*(include|define|if|ifdef|ifndef|else|elif|endif|pragma)\\b", "Annotation");
                QStringList cppTypes = {"public", "private", "protected", "static", "const", "constexpr", "auto"};
                for (const QString &t : cppTypes) addRule("\\b" + t + "\\b", "Type");
            } else if (m_language == "javascript") {
                QStringList jsTypes = {"var", "let", "const", "undefined"};
                for (const QString &t : jsTypes) addRule("\\b" + t + "\\b", "Type");
                QStringList jsKeywords = {"function", "export", "import", "async", "await", "in", "of", "new"};
                for (const QString &k : jsKeywords) addRule("\\b" + k + "\\b", "Keyword");
            } else if (m_language == "java" || m_language == "csharp") {
                addRule("@[A-Za-z0-9_]+", "Annotation");
                if (m_language == "csharp") addRule("\\[[A-Za-z0-9_]+\\]", "Annotation");
                QStringList oopTypes = {"public", "private", "protected", "static", "final", "readonly", "new"};
                for (const QString &t : oopTypes) addRule("\\b" + t + "\\b", "Type");
            } else if (m_language == "rust") {
                QStringList rustTypes = {"i8", "i16", "i32", "i64", "u8", "u16", "u32", "u64", "f32", "f64", "str", "mut", "pub"};
                for (const QString &t : rustTypes) addRule("\\b" + t + "\\b", "Type");
                QStringList rustKeywords = {"fn", "match", "loop", "use", "crate", "impl", "type", "let"};
                for (const QString &k : rustKeywords) addRule("\\b" + k + "\\b", "Keyword");
            } else if (m_language == "go") {
                QStringList goTypes = {"chan", "byte", "rune", "error"};
                for (const QString &t : goTypes) addRule("\\b" + t + "\\b", "Type");
                QStringList goKeywords = {"func", "go", "defer", "package", "import", "type", "var"};
                for (const QString &k : goKeywords) addRule("\\b" + k + "\\b", "Keyword");
            }
        }
    }
};

class SyntaxHighlighterProxy : public QObject {
    Q_OBJECT
    Q_PROPERTY(QQuickTextDocument* document READ document WRITE setDocument NOTIFY documentChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString activeWord READ activeWord WRITE setActiveWord NOTIFY activeWordChanged)

public:
    SyntaxHighlighterProxy(QObject *parent = nullptr) : QObject(parent) {}

    QQuickTextDocument* document() const { return m_document; }
    void setDocument(QQuickTextDocument* doc) {
        if (m_document == doc) return;
        m_document = doc;
        updateHighlighter();
        emit documentChanged();
    }

    QString language() const { return m_language; }
    void setLanguage(const QString &lang) {
        if (m_language == lang) return;
        m_language = lang;
        updateHighlighter();
        emit languageChanged();
    }

    QString activeWord() const { return m_activeWord; }
    void setActiveWord(const QString &word) {
        if (m_activeWord == word) return;
        m_activeWord = word;
        if (m_highlighter) {
            m_highlighter->setActiveWord(m_activeWord);
            m_highlighter->rehighlight();
        }
        emit activeWordChanged();
    }

signals:
    void documentChanged();
    void languageChanged();
    void activeWordChanged();

private:
    QQuickTextDocument* m_document = nullptr;
    AdvancedHighlighter* m_highlighter = nullptr;
    QString m_language = "javascript";
    QString m_activeWord = "";

    void updateHighlighter() {
        if (m_highlighter) {
            m_highlighter->deleteLater();
            m_highlighter = nullptr;
        }
        if (m_document) {
            m_highlighter = new AdvancedHighlighter(m_language, m_document->textDocument());
        }
    }
};
#endif // HIGHLIGHTER_H
