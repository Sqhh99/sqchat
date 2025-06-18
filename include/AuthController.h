#ifndef AUTHCONTROLLER_H
#define AUTHCONTROLLER_H

#include <QObject>
#include <QTimer>
#include <memory>
#include "NetworkManager.h"
#include "Message.h"

/**
 * @brief 认证控制器
 * 处理登录、注册、验证码等认证相关功能
 * 与NetworkManager协作，提供高级的认证API
 */
class AuthController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY loginStateChanged)
    Q_PROPERTY(QString currentUserId READ currentUserId NOTIFY currentUserChanged)
    Q_PROPERTY(QString currentUsername READ currentUsername NOTIFY currentUserChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionStateChanged)

public:
    explicit AuthController(QObject *parent = nullptr);
    ~AuthController();

    // 状态查询
    bool isLoggedIn() const { return m_isLoggedIn; }
    QString currentUserId() const { return m_currentUserId; }
    QString currentUsername() const { return m_currentUsername; }
    bool isConnected() const;

    // 设置网络管理器
    void setNetworkManager(NetworkManager *networkManager);
    NetworkManager* networkManager() const { return m_networkManager; }

public slots:
    // 连接管理
    void connectToServer();
    void disconnectFromServer();
    
    // 认证操作
    void login(const QString &username, const QString &password);
    void logout();
    void registerUser(const QString &username, const QString &email, 
                     const QString &password, const QString &verifyCode);
    void sendVerifyCode(const QString &email);

signals:
    // 状态变化信号
    void loginStateChanged();
    void currentUserChanged();
    void connectionStateChanged();
    
    // 操作结果信号
    void loginSuccess(const QString &userId, const QString &username);
    void loginFailed(const QString &error);
    void logoutSuccess();
    void logoutFailed(const QString &error);
    
    void registerSuccess(const QString &userId);
    void registerFailed(const QString &error);
    
    void verifyCodeSent();
    void verifyCodeFailed(const QString &error);
    
    // 连接状态信号
    void connected();
    void disconnected();
    void connectionError(const QString &error);

private slots:
    // 网络事件处理
    void onNetworkConnected();
    void onNetworkDisconnected();
    void onNetworkError(const QString &error);
    void onMessageReceived(const Message *message);
    
    // 超时处理
    void onOperationTimeout();

private:
    // 网络管理器
    NetworkManager *m_networkManager;
    bool m_ownNetworkManager; // 是否拥有NetworkManager的所有权
    
    // 用户状态
    bool m_isLoggedIn;
    QString m_currentUserId;
    QString m_currentUsername;
    
    // 操作状态
    enum class PendingOperation {
        None,
        Login,
        Logout,
        Register,
        VerifyCode
    };
    PendingOperation m_pendingOperation;
    std::unique_ptr<QTimer> m_operationTimer;
    
    // 私有方法
    void initializeComponents();
    void handleLoginResponse(const Message *message);
    void handleLogoutResponse(const Message *message);
    void handleRegisterResponse(const Message *message);
    void handleVerifyCodeResponse(const Message *message);
    void resetUserState();
    void startOperationTimer(int timeoutMs = 10000); // 默认10秒超时
    void stopOperationTimer();
    void setPendingOperation(PendingOperation operation);
};

#endif // AUTHCONTROLLER_H