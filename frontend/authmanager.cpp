#include "AuthManager.h"
#include <QNetworkRequest>
#include <QUrl>
#include <QJsonObject>
#include <QJsonDocument>

AuthManager::AuthManager(QObject *parent) : QObject(parent)
{
    networkManager = new QNetworkAccessManager(this);
    connect(networkManager, &QNetworkAccessManager::finished, this, &AuthManager::onReplyFinished);
}

void AuthManager::login(const QString &username, const QString &password)
{
    QUrl url("http://localhost:8080/api/login");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject json;
    json["username"] = username;
    json["password"] = password;
    QJsonDocument doc(json);

    networkManager->post(request, doc.toJson());
}

void AuthManager::onReplyFinished(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObj = jsonDoc.object();

        if (jsonObj["status"].toString() == "success")
        {
            int xp = jsonObj["total_xp"].toInt();
            emit loginSuccess(xp);
        }
        else
        {
            emit loginFailed(jsonObj["message"].toString());
        }
    }
    else
    {
        emit loginFailed("Network error: Cannot connect to server.");
    }
    reply->deleteLater();
}
