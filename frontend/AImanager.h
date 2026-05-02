#ifndef AIMANAGER_H
#define AIMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class AIManager : public QObject
{
    Q_OBJECT

public:
    explicit AIManager(QObject *parent = nullptr);

    Q_INVOKABLE void fetchHint(const QString &problemDescription, const QString &userCode);

signals:
    void hintReceived(const QString &hint);
    void requestFailed(const QString &errorMessage);

private slots:
    void onReplyFinished(QNetworkReply *reply);

private:
    QNetworkAccessManager *networkManager;
};

#endif // AIMANAGER_H