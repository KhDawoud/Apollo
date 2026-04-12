#ifndef CODEEDITOR_H
#define CODEEDITOR_H
#pragma once

#include <QWidget>
#include <Qsci/qsciscintilla.h>
#include <Qsci/qscilexerjavascript.h>

class CodeEditor : public QsciScintilla
{
    Q_OBJECT
public:
    CodeEditor(QWidget *parent = nullptr);
};
#endif // CODEEDITOR_H
