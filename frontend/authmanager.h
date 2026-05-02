#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QString>
#include <QVariant>

class AuthManager : public QObject
{
    Q_OBJECT
public:
    explicit AuthManager(QObject *parent = nullptr);

    // Q_INVOKABLE makes these callable directly from QML
    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void signup(const QString &email, const QString &username, const QString &password);
    Q_INVOKABLE void fetchProblemsList(const QString &language);
    Q_INVOKABLE void fetchProblem(int id);

signals:
    void loginSuccess(int totalXp);
    void loginFailed(const QString &errorMessage);

    void signupSuccess(int totalXp);
    void signupFailed(const QString &errorMessage);

    void fetchProblemsListSuccess(QVariantList problems);
    void fetchProblemsListFailed(const QString &errorMessage);

    void fetchProblemSuccess(QVariantMap problem);
    void fetchProblemFailed(const QString &errorMessage);


private slots:
    void onLoginReply(QNetworkReply *reply);
    void onSignupReply(QNetworkReply *reply);
    void onFetchProblemsList(QNetworkReply *reply);
    void onFetchProblem(QNetworkReply *reply);

private:
    QNetworkAccessManager *networkManager;
};

#endif // AUTHMANAGER_H
