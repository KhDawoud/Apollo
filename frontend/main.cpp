#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "Highlighter.h"
#include "authmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");
    AuthManager authManager;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("authManager", &authManager);
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
