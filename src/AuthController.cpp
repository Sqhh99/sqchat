#include "include/AuthController.h"
#include <QDebug>

AuthController::AuthController(QObject *parent)
    : QObject(parent)
    , m_networkManager(nullptr)
    , m_ownNetworkManager(false)
    , m_isLoggedIn(false)
    , m_pendingOperation(PendingOperation::None)
{
    initializeComponents();
}

AuthController::~AuthController()
{
    if (m_ownNetworkManager && m_networkManager) {
        delete m_networkManager;
    }
}

void AuthController::initializeComponents()
{
    // 初始化操作超时定时器
    m_operationTimer = std::make_unique<QTimer>(this);
    m_operationTimer->setSingleShot(true);
    connect(m_operationTimer.get(), &QTimer::timeout, 
            this, &AuthController::onOperationTimeout);
}

bool AuthController::isConnected() const
{
    return m_networkManager ? m_networkManager->isConnected() : false;
}

void AuthController::setNetworkManager(NetworkManager *networkManager)
{
    // 断开旧的连接
    if (m_networkManager) {
        disconnect(m_networkManager, nullptr, this, nullptr);
        if (m_ownNetworkManager) {
            delete m_networkManager;
        }
    }
    
    m_networkManager = networkManager;
    m_ownNetworkManager = false;
    
    if (m_networkManager) {
        // 连接新的信号
        connect(m_networkManager, &NetworkManager::connected,
                this, &AuthController::onNetworkConnected);
        connect(m_networkManager, &NetworkManager::disconnected,
                this, &AuthController::onNetworkDisconnected);
        connect(m_networkManager, &NetworkManager::connectionError,
                this, &AuthController::onNetworkError);
        connect(m_networkManager, &NetworkManager::messageReceived,
                this, &AuthController::onMessageReceived);
        connect(m_networkManager, &NetworkManager::connectedChanged,
                this, &AuthController::connectionStateChanged);
    }
    
    emit connectionStateChanged();
}

void AuthController::connectToServer()
{
    if (!m_networkManager) {
        // 如果没有设置NetworkManager，创建一个默认的
        m_networkManager = new NetworkManager(this);
        m_ownNetworkManager = true;
        setNetworkManager(m_networkManager);
    }
    
    m_networkManager->connectToServer();
}

void AuthController::disconnectFromServer()
{
    if (m_networkManager) {
        m_networkManager->disconnectFromServer();
    }
    resetUserState();
}

void AuthController::login(const QString &username, const QString &password)
{
    if (!m_networkManager || !m_networkManager->isConnected()) {
        emit loginFailed("未连接到服务器");
        return;
    }
    
    if (m_pendingOperation != PendingOperation::None) {
        emit loginFailed("有操作正在进行中，请稍后再试");
        return;
    }
    
    QVariantMap data;
    data["username"] = username;
    data["password"] = password;
    
    m_networkManager->sendMessage(MessageType::LOGIN_REQUEST, data);
    
    setPendingOperation(PendingOperation::Login);
    startOperationTimer();
    
    qDebug() << "Login request sent for user:" << username;
}

void AuthController::logout()
{
    if (!m_networkManager || !m_networkManager->isConnected()) {
        resetUserState();
        emit logoutSuccess();
        return;
    }
    
    if (!m_isLoggedIn) {
        emit logoutSuccess();
        return;
    }
    
    QVariantMap data;
    data["userId"] = m_currentUserId;
    
    m_networkManager->sendMessage(MessageType::LOGOUT_REQUEST, data);
    
    setPendingOperation(PendingOperation::Logout);
    startOperationTimer();
    
    qDebug() << "Logout request sent for user:" << m_currentUserId;
}

void AuthController::registerUser(const QString &username, const QString &email, 
                                const QString &password, const QString &verifyCode)
{
    if (!m_networkManager || !m_networkManager->isConnected()) {
        emit registerFailed("未连接到服务器");
        return;
    }
    
    if (m_pendingOperation != PendingOperation::None) {
        emit registerFailed("有操作正在进行中，请稍后再试");
        return;
    }
    
    QVariantMap data;
    data["username"] = username;
    data["email"] = email;
    data["password"] = password;
    data["code"] = verifyCode;
    
    m_networkManager->sendMessage(MessageType::REGISTER_REQUEST, data);
    
    setPendingOperation(PendingOperation::Register);
    startOperationTimer();
    
    qDebug() << "Register request sent for user:" << username << "email:" << email;
}

void AuthController::sendVerifyCode(const QString &email)
{
    if (!m_networkManager || !m_networkManager->isConnected()) {
        emit verifyCodeFailed("未连接到服务器");
        return;
    }
    
    if (m_pendingOperation != PendingOperation::None) {
        emit verifyCodeFailed("有操作正在进行中，请稍后再试");
        return;
    }
    
    QVariantMap data;
    data["email"] = email;
    
    m_networkManager->sendMessage(MessageType::VERIFY_CODE_REQUEST, data);
    
    setPendingOperation(PendingOperation::VerifyCode);
    startOperationTimer();
    
    qDebug() << "Verify code request sent for email:" << email;
}

void AuthController::onNetworkConnected()
{
    qDebug() << "Network connected";
    emit connected();
}

void AuthController::onNetworkDisconnected()
{
    qDebug() << "Network disconnected";
    resetUserState();
    emit disconnected();
}

void AuthController::onNetworkError(const QString &error)
{
    qDebug() << "Network error:" << error;
    
    // 如果有正在进行的操作，报告错误
    if (m_pendingOperation != PendingOperation::None) {
        stopOperationTimer();
        
        switch (m_pendingOperation) {
        case PendingOperation::Login:
            emit loginFailed(QString("网络错误: %1").arg(error));
            break;
        case PendingOperation::Logout:
            emit logoutFailed(QString("网络错误: %1").arg(error));
            break;
        case PendingOperation::Register:
            emit registerFailed(QString("网络错误: %1").arg(error));
            break;
        case PendingOperation::VerifyCode:
            emit verifyCodeFailed(QString("网络错误: %1").arg(error));
            break;
        default:
            break;
        }
        
        m_pendingOperation = PendingOperation::None;
    }
    
    emit connectionError(error);
}

void AuthController::onMessageReceived(const Message *message)
{
    if (!message) return;
    
    switch (message->type()) {
    case MessageType::LOGIN_RESPONSE:
        handleLoginResponse(message);
        break;
    case MessageType::LOGOUT_RESPONSE:
        handleLogoutResponse(message);
        break;
    case MessageType::REGISTER_RESPONSE:
        handleRegisterResponse(message);
        break;
    case MessageType::VERIFY_CODE_RESPONSE:
        handleVerifyCodeResponse(message);
        break;
    default:
        // 其他类型的消息不在此处处理
        break;
    }
}

void AuthController::handleLoginResponse(const Message *message)
{
    if (m_pendingOperation != PendingOperation::Login) {
        return;
    }
    
    stopOperationTimer();
    m_pendingOperation = PendingOperation::None;
    
    QString status = message->getData("status").toString();
      if (status == "0") {
        // 登录成功
        m_isLoggedIn = true;
        m_currentUserId = message->getData("userId").toString();
        m_currentUsername = message->getData("username").toString();
        
        emit loginStateChanged();
        emit currentUserChanged();
        emit loginSuccess(m_currentUserId, m_currentUsername);
        emit userLoggedIn(m_currentUserId); // 新增信号，用于初始化聊天历史
        
        qDebug() << "Login successful. User ID:" << m_currentUserId 
                 << "Username:" << m_currentUsername;
    } else {
        // 登录失败
        QString errorMessage = message->getData("message", "登录失败").toString();
        emit loginFailed(errorMessage);
        
        qDebug() << "Login failed:" << errorMessage;
    }
}

void AuthController::handleLogoutResponse(const Message *message)
{
    if (m_pendingOperation != PendingOperation::Logout) {
        return;
    }
    
    stopOperationTimer();
    m_pendingOperation = PendingOperation::None;
    
    QString status = message->getData("status").toString();
    
    if (status == "0") {
        resetUserState();
        emit logoutSuccess();
        qDebug() << "Logout successful";
    } else {
        QString errorMessage = message->getData("message", "登出失败").toString();
        emit logoutFailed(errorMessage);
        qDebug() << "Logout failed:" << errorMessage;
    }
}

void AuthController::handleRegisterResponse(const Message *message)
{
    if (m_pendingOperation != PendingOperation::Register) {
        return;
    }
    
    stopOperationTimer();
    m_pendingOperation = PendingOperation::None;
    
    QString status = message->getData("status").toString();
    
    if (status == "0") {
        QString userId = message->getData("userid").toString(); // 注意这里是userid，不是userId
        emit registerSuccess(userId);
        qDebug() << "Register successful. User ID:" << userId;
    } else {
        QString errorMessage = message->getData("message", "注册失败").toString();
        emit registerFailed(errorMessage);
        qDebug() << "Register failed:" << errorMessage;
    }
}

void AuthController::handleVerifyCodeResponse(const Message *message)
{
    if (m_pendingOperation != PendingOperation::VerifyCode) {
        return;
    }
    
    stopOperationTimer();
    m_pendingOperation = PendingOperation::None;
    
    QString status = message->getData("status").toString();
    
    if (status == "0") {
        emit verifyCodeSent();
        qDebug() << "Verify code sent successfully";
    } else {
        QString errorMessage = message->getData("message", "验证码发送失败").toString();
        emit verifyCodeFailed(errorMessage);
        qDebug() << "Verify code sending failed:" << errorMessage;
    }
}

void AuthController::onOperationTimeout()
{
    qWarning() << "Operation timeout";
    
    switch (m_pendingOperation) {
    case PendingOperation::Login:
        emit loginFailed("操作超时，请检查网络连接");
        break;
    case PendingOperation::Logout:
        emit logoutFailed("操作超时，请检查网络连接");
        break;
    case PendingOperation::Register:
        emit registerFailed("操作超时，请检查网络连接");
        break;
    case PendingOperation::VerifyCode:
        emit verifyCodeFailed("操作超时，请检查网络连接");
        break;
    default:
        break;
    }
    
    m_pendingOperation = PendingOperation::None;
}

void AuthController::resetUserState()
{
    if (m_isLoggedIn) {
        m_isLoggedIn = false;
        emit loginStateChanged();
    }
    
    if (!m_currentUserId.isEmpty() || !m_currentUsername.isEmpty()) {
        m_currentUserId.clear();
        m_currentUsername.clear();
        emit currentUserChanged();
    }
}

void AuthController::startOperationTimer(int timeoutMs)
{
    m_operationTimer->start(timeoutMs);
}

void AuthController::stopOperationTimer()
{
    if (m_operationTimer->isActive()) {
        m_operationTimer->stop();
    }
}

void AuthController::setPendingOperation(PendingOperation operation)
{
    m_pendingOperation = operation;
}