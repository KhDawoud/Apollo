#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QString>
#include <QJsonObject>

class AuthManager : public QObject
{
    Q_OBJECT
public:
    explicit AuthManager(QObject *parent = nullptr);

    // Q_INVOKABLE makes these callable directly from QML
    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void signup(const QString &email, const QString &username, const QString &password);
    Q_INVOKABLE void fetchleaderboard();

signals:
    void loginSuccess(int totalXp, int streak, QString name);
    void loginFailed(const QString &errorMessage);

    void signupSuccess(int totalXp, int streak, QString name);
    void signupFailed(const QString &errorMessage);
    void leaderboardReceived(QVariantList leaderboardData);

private slots:
    void onLoginReply(QNetworkReply *reply);
    void onSignupReply(QNetworkReply *reply);

private:
    QNetworkAccessManager *networkManager;
};

#endif // AUTHMANAGER_H
