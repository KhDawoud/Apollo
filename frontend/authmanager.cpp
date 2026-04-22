#include "authmanager.h"
#include "utils.hpp"
#include <QNetworkRequest>
#include <QUrl>
#include <QJsonObject>
#include <QJsonDocument>
#include <QByteArray>

AuthManager::AuthManager(QObject *parent) : QObject(parent)
{
    networkManager = new QNetworkAccessManager(this);
}

void AuthManager::login(const QString &username, const QString &password)
{
    QUrl url("http://localhost:8080/api/login");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    bool isemail = username.contains('@'); //checks if it is an email or a username

    if(isemail){
        //checks if email is in correct format
        try{
            checkemail(username.toStdString());
        }catch(const std::invalid_argument& e){
            emit loginFailed("Invalid email format. Please check your email address.");
            return;
        }
    }else{
        //Username length check
        if (username.length() < 4) {
            emit loginFailed("Username must be at least 4 characters long.");
            return;
        }
    }
    // Password length check
    if (password.length() < 8) {
        emit loginFailed("Password must be at least 8 characters long.");
        return;
    }

    QJsonObject json;
    json["identifier"] = username;
    json["password"] = password;
    QJsonDocument doc(json);

    QNetworkReply *reply = networkManager->post(request, doc.toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { onLoginReply(reply); });
}

void AuthManager::onLoginReply(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObj = jsonDoc.object();

        if (jsonObj["status"].toString() == "success")
        {
            int xp = jsonObj["total_xp"].toInt();
            int streak = jsonObj["daily_streak"].toInt();
            emit loginSuccess(xp,streak);
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

void AuthManager::signup(const QString &email, const QString &username, const QString &password)
{
    QUrl url("http://localhost:8080/api/signup");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    // Email validity check 
    try{
        checkemail(email.toStdString());
    }catch(const std::invalid_argument& e){
        emit signupFailed("Invalid email format. Please check your email address.");
        return;
    }

    //Username length check
    if (username.length() < 4) {
        emit signupFailed("Username must be at least 4 characters long.");
        return;
    }

    // Password length check
    if (password.length() < 8) {
        emit signupFailed("Password must be at least 8 characters long.");
        return;
    }
    QJsonObject json;
    json["email"] = email;
    json["username"] = username;
    json["password"] = password;
    QJsonDocument doc(json);

    QNetworkReply *reply = networkManager->post(request, doc.toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            { onSignupReply(reply); });
}

void AuthManager::onSignupReply(QNetworkReply *reply)
{
    // 200 and 201 means it worked 409 means username or email taken
    if (reply->error() == QNetworkReply::NoError || reply->error() == QNetworkReply::ContentConflictError)
    {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObj = jsonDoc.object();

        if (jsonObj["status"].toString() == "success")
        {
            int xp = jsonObj["total_xp"].toInt();
            int streak = jsonObj["daily_streak"].toInt();
            emit signupSuccess(xp,streak);
        }
        else
        {
            emit signupFailed(jsonObj["message"].toString());
        }
    }
    else
    {
        emit signupFailed("Network error: Cannot connect to server.");
    }
    reply->deleteLater();
}
