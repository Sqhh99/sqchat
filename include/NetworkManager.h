#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QTcpSocket>
#include <QTimer>
#include <QQueue>
#include <QMutex>
#include <QThread>
#include <memory>
#include "Message.h"

/**
 * @brief 网络管理器
 * 负责与服务器的TCP连接、消息发送接收和心跳维护
 * 支持异步操作，避免界面卡顿
 */
class NetworkManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged)
    Q_PROPERTY(QString serverHost READ serverHost WRITE setServerHost NOTIFY serverHostChanged)
    Q_PROPERTY(int serverPort READ serverPort WRITE setServerPort NOTIFY serverPortChanged)

public:
    explicit NetworkManager(QObject *parent = nullptr);
    ~NetworkManager();

    // 连接状态
    bool isConnected() const;
    
    // 服务器配置
    QString serverHost() const { return m_serverHost; }
    void setServerHost(const QString &host);
    
    int serverPort() const { return m_serverPort; }
    void setServerPort(int port);

public slots:
    // 连接管理
    void connectToServer();
    void disconnectFromServer();
    
    // 消息发送
    void sendMessage(const Message *message);
    void sendMessage(MessageType type, const QVariantMap &data);
    
    // 心跳管理
    void startHeartbeat(int intervalMs = 20000); // 默认20秒
    void stopHeartbeat();

signals:
    // 连接状态信号
    void connectedChanged();
    void connected();
    void disconnected();
    void connectionError(const QString &error);
    
    // 消息信号
    void messageReceived(const Message *message);
    void messageSent(const Message *message);
    
    // 服务器配置信号
    void serverHostChanged();
    void serverPortChanged();

private slots:
    // Socket事件处理
    void onSocketConnected();
    void onSocketDisconnected();
    void onSocketError(QAbstractSocket::SocketError error);
    void onSocketReadyRead();
    
    // 心跳处理
    void sendHeartbeat();

private:
    // 网络组件
    std::unique_ptr<QTcpSocket> m_socket;
    std::unique_ptr<QTimer> m_heartbeatTimer;
    
    // 服务器配置
    QString m_serverHost;
    int m_serverPort;
    
    // 消息缓冲
    QString m_messageBuffer;
    QQueue<std::shared_ptr<Message>> m_sendQueue;
    QMutex m_sendMutex;
      // 状态
    bool m_isConnected;
    qint64 m_connectionStartTime;  // 连接开始时间
    
    // 私有方法
    void processReceivedData(const QString &data);
    void processMessage(const QString &messageString);
    void sendQueuedMessages();
    void initializeComponents();
};

#endif // NETWORKMANAGER_H