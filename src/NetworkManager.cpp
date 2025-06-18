#include "include/NetworkManager.h"
#include <QDebug>
#include <QHostAddress>
#include <QMutexLocker>
#include <QRegularExpression>

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent)
    , m_serverHost("127.0.0.1")  // 直接使用IP地址而不是localhost
    , m_serverPort(8888)
    , m_isConnected(false)
    , m_connectionStartTime(0)
{
    initializeComponents();
}

NetworkManager::~NetworkManager()
{
    if (m_socket && m_socket->state() == QAbstractSocket::ConnectedState) {
        m_socket->disconnectFromHost();
    }
    stopHeartbeat();
}

void NetworkManager::initializeComponents()
{
    // 初始化Socket
    m_socket = std::make_unique<QTcpSocket>(this);
    
    // 优化TCP连接选项 - 更激进的优化
    m_socket->setSocketOption(QAbstractSocket::LowDelayOption, 1);
    m_socket->setSocketOption(QAbstractSocket::KeepAliveOption, 1);
    
    // 尝试禁用Nagle算法（如果支持）
    #ifdef TCP_NODELAY
    m_socket->setSocketOption(QAbstractSocket::LowDelayOption, 1);
    #endif
    
    // 连接Socket信号
    connect(m_socket.get(), &QTcpSocket::connected, 
            this, &NetworkManager::onSocketConnected);
    connect(m_socket.get(), &QTcpSocket::disconnected, 
            this, &NetworkManager::onSocketDisconnected);
    connect(m_socket.get(), QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::errorOccurred),
            this, &NetworkManager::onSocketError);
    connect(m_socket.get(), &QTcpSocket::readyRead, 
            this, &NetworkManager::onSocketReadyRead);
    
    // 初始化心跳定时器
    m_heartbeatTimer = std::make_unique<QTimer>(this);
    connect(m_heartbeatTimer.get(), &QTimer::timeout, 
            this, &NetworkManager::sendHeartbeat);
}

bool NetworkManager::isConnected() const
{
    return m_isConnected;
}

void NetworkManager::setServerHost(const QString &host)
{
    if (m_serverHost != host) {
        m_serverHost = host;
        emit serverHostChanged();
    }
}

void NetworkManager::setServerPort(int port)
{
    if (m_serverPort != port) {
        m_serverPort = port;
        emit serverPortChanged();
    }
}

void NetworkManager::connectToServer()
{
    if (m_socket->state() == QAbstractSocket::ConnectedState) {
        qDebug() << "Already connected to server";
        return;
    }
    
    if (m_socket->state() == QAbstractSocket::ConnectingState) {
        qDebug() << "Connection already in progress";
        return;
    }    qDebug() << "Connecting to server:" << m_serverHost << ":" << m_serverPort;
    
    // 记录连接开始时间
    m_connectionStartTime = QDateTime::currentMSecsSinceEpoch();
    
    // 使用QHostAddress直接连接，避免DNS解析
    QHostAddress address(m_serverHost);
    if (address.isNull()) {
        // 如果不是有效的IP地址，使用默认的connectToHost
        qDebug() << "Using hostname connection";
        m_socket->connectToHost(m_serverHost, static_cast<quint16>(m_serverPort));
    } else {
        // 直接使用IP地址连接，避免DNS查找
        qDebug() << "Using direct IP connection";
        m_socket->connectToHost(address, static_cast<quint16>(m_serverPort));
    }
}

void NetworkManager::disconnectFromServer()
{
    stopHeartbeat();
    
    if (m_socket->state() == QAbstractSocket::ConnectedState) {
        m_socket->disconnectFromHost();
    }
}

void NetworkManager::sendMessage(const Message *message)
{
    if (!message) {
        qWarning() << "Cannot send null message";
        return;
    }
    
    if (!m_isConnected) {
        qWarning() << "Not connected to server, cannot send message";
        return;
    }
    
    QString messageString = message->toString() + "\n";
    QByteArray data = messageString.toUtf8();
    
    qint64 bytesWritten = m_socket->write(data);
    if (bytesWritten == -1) {
        qWarning() << "Failed to send message:" << m_socket->errorString();
        return;
    }
    
    m_socket->flush();
    qDebug() << "Message sent:" << message->toString();
    emit messageSent(message);
}

void NetworkManager::sendMessage(MessageType type, const QVariantMap &data)
{
    auto message = std::make_unique<Message>(type, data, this);
    sendMessage(message.get());
}

void NetworkManager::startHeartbeat(int intervalMs)
{
    if (m_heartbeatTimer->isActive()) {
        m_heartbeatTimer->stop();
    }
    
    m_heartbeatTimer->setInterval(intervalMs);
    m_heartbeatTimer->start();
    qDebug() << "Heartbeat started with interval:" << intervalMs << "ms";
}

void NetworkManager::stopHeartbeat()
{
    if (m_heartbeatTimer->isActive()) {
        m_heartbeatTimer->stop();
        qDebug() << "Heartbeat stopped";
    }
}

void NetworkManager::onSocketConnected()
{
    m_isConnected = true;
    
    // 计算连接时间
    if (m_connectionStartTime > 0) {
        auto endTime = QDateTime::currentMSecsSinceEpoch();
        auto connectionTime = endTime - m_connectionStartTime;
        qDebug() << "Connected to server in" << connectionTime << "ms";
        m_connectionStartTime = 0; // 重置
    } else {
        qDebug() << "Connected to server";
    }
    
    // 清空消息缓冲
    m_messageBuffer.clear();
    
    emit connectedChanged();
    emit connected();
    
    // 开始心跳
    startHeartbeat();
}

void NetworkManager::onSocketDisconnected()
{
    m_isConnected = false;
    qDebug() << "Disconnected from server";
    
    stopHeartbeat();
    
    emit connectedChanged();
    emit disconnected();
}

void NetworkManager::onSocketError(QAbstractSocket::SocketError error)
{
    Q_UNUSED(error)
    QString errorString = m_socket->errorString();
    qWarning() << "Socket error:" << errorString;
    
    m_isConnected = false;
    emit connectedChanged();
    emit connectionError(errorString);
}

void NetworkManager::onSocketReadyRead()
{
    QByteArray data = m_socket->readAll();
    QString receivedData = QString::fromUtf8(data);
    
    // 将接收到的数据添加到缓冲区
    m_messageBuffer += receivedData;
    
    // 处理完整的消息（以换行符分隔）
    processReceivedData(m_messageBuffer);
}

void NetworkManager::processReceivedData(const QString &data)
{
    QStringList messages = data.split('\n', Qt::KeepEmptyParts);
    
    // 最后一个元素可能是不完整的消息，保留在缓冲区
    if (!messages.isEmpty()) {
        m_messageBuffer = messages.takeLast();
        
        // 处理完整的消息
        for (const QString &messageString : messages) {
            if (!messageString.trimmed().isEmpty()) {
                processMessage(messageString.trimmed());
            }
        }
    }
    
    // 如果缓冲区中的消息看起来是完整的（包含冒号且没有换行符），立即处理
    if (!m_messageBuffer.isEmpty() && m_messageBuffer.contains(':') && !m_messageBuffer.contains('\n')) {
        // 检查是否像一个完整的消息（数字:内容格式）
        QRegularExpression messagePattern("^\\d+:");
        if (messagePattern.match(m_messageBuffer).hasMatch()) {
            processMessage(m_messageBuffer.trimmed());
            m_messageBuffer.clear();
        }
    }
}

void NetworkManager::processMessage(const QString &messageString)
{
    qDebug() << "Message received:" << messageString;
    
    Message *message = Message::fromString(messageString, this);
    if (message) {
        emit messageReceived(message);
        // 消息会在处理完成后由Qt的对象树自动删除
    } else {
        qWarning() << "Failed to parse message:" << messageString;
    }
}

void NetworkManager::sendHeartbeat()
{
    if (m_isConnected) {
        QVariantMap data;
        data["timestamp"] = QString::number(QDateTime::currentMSecsSinceEpoch());
        sendMessage(MessageType::HEARTBEAT_REQUEST, data);
    }
}