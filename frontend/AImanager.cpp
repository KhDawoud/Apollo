#include "AImanager.h"
#include <QNetworkRequest>
#include <QUrl>
#include <QJsonObject>
#include <QJsonDocument>

AIManager::AIManager(QObject *parent) : QObject(parent)
{
    networkManager = new QNetworkAccessManager(this);
}

void AIManager::fetchHint(const QString &problemDescription, const QString &userCode)
{
    QUrl url("http://localhost:8080/api/ask_ai");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject json;
    json["problem_description"] = problemDescription;
    json["code"] = userCode;
    QJsonDocument doc(json);

    QNetworkReply *reply = networkManager->post(request, doc.toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { onReplyFinished(reply); });
}

void AIManager::onReplyFinished(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObj = jsonDoc.object();

        if (jsonObj["status"].toString() == "success")
        {
            emit hintReceived(jsonObj["hint"].toString());
        }
        else
        {
            emit requestFailed(jsonObj["message"].toString());
        }
    }
    else
    {
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QString errorMsg = "Unable to reach the AI assistant. (Error " + QString::number(statusCode) + ")";
        emit requestFailed(errorMsg);
    }

    reply->deleteLater();
}