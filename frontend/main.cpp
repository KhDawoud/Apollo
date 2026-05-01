#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "Highlighter.h"
#include "authmanager.h"
#include "AImanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    // I made it basic because it interfered with some styling
    QQuickStyle::setStyle("Basic");
    AuthManager authManager;
    QQmlApplicationEngine engine;
    // inject the code we plan to use for login in (we only do it once so it shouldnt be a component)
    engine.rootContext()->setContextProperty("authManager", &authManager);
    // makes these connections into an actual QML component
    qmlRegisterType<SyntaxHighlighterProxy>("Apollo.Code", 1, 0, "SyntaxHighlighter");
    qmlRegisterType<AIManager>("Apollo.Backend", 1, 0, "AIManager");
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Apollo", "Main");

    return app.exec();
}
