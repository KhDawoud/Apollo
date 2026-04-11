#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include "Highlighter.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");
    QQmlApplicationEngine engine;
    qmlRegisterType<SyntaxHighlighterProxy>("Apollo.Code", 1, 0, "SyntaxHighlighter");
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Apollo", "Main");

    return app.exec();
}
