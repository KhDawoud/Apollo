#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QString>

class AuthManager : public QObject
{
    Q_OBJECT
public:
    explicit AuthManager(QObject *parent = nullptr);

    // Q_INVOKABLE makes these callable directly from QML
    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void signup(const QString &email, const QString &username, const QString &password);

signals:
    void loginSuccess(int totalXp, int streak);
    void loginFailed(const QString &errorMessage);

    void signupSuccess(int totalXp, int streak);
    void signupFailed(const QString &errorMessage);

private slots:
    void onLoginReply(QNetworkReply *reply);
    void onSignupReply(QNetworkReply *reply);

private:
    QNetworkAccessManager *networkManager;
};

#endif // AUTHMANAGER_H
