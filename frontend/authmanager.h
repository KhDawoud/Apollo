#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class AuthManager : public QObject
{
    Q_OBJECT
public:
    explicit AuthManager(QObject *parent = nullptr);

    // Q_INVOKABLE so it can be used directly in the code
    Q_INVOKABLE void login(const QString &username, const QString &password);

signals:
    void loginSuccess(int totalXp);
    void loginFailed(QString errorMessage);

private slots:
    void onReplyFinished(QNetworkReply *reply);

private:
    QNetworkAccessManager *networkManager;
};

#endif // AUTHMANAGER_H
