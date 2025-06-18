#pragma once

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <qqml.h>

class NetworkManager;
class Message;
class ChatHistoryManager;

/**
 * @brief 聊天控制器类
 * 负责处理聊天消息、好友管理、群组管理等功能
 */
class ChatController : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectedChanged)
    Q_PROPERTY(QVariantList friendsList READ friendsList NOTIFY friendsListChanged)
    Q_PROPERTY(QVariantList groupsList READ groupsList NOTIFY groupsListChanged)
    Q_PROPERTY(QVariantList usersList READ usersList NOTIFY usersListChanged)

public:
    explicit ChatController(QObject *parent = nullptr);
    
    void setNetworkManager(NetworkManager *manager);
    void setChatHistoryManager(ChatHistoryManager *manager);
    
    bool isConnected() const;
    QVariantList friendsList() const { return m_friendsList; }
    QVariantList groupsList() const { return m_groupsList; }
    QVariantList usersList() const { return m_usersList; }

public slots:
    // 消息发送
    void sendPrivateMessage(const QString &toUserId, const QString &content);
    void sendGroupMessage(const QString &groupId, const QString &content);
    
    // 好友管理
    void getFriendsList();
    void addFriend(const QString &friendId);
    void acceptFriendRequest(const QString &fromUserId);
    void rejectFriendRequest(const QString &fromUserId);
    void getFriendRequests();
    
    // 群组管理
    void getGroupsList();
    void createGroup(const QString &groupName);
    void joinGroup(const QString &groupId);
    void leaveGroup(const QString &groupId);
    void getGroupMembers(const QString &groupId);
    
    // 用户列表
    void getUsersList();
      // 聊天历史
    void getChatHistory(const QString &type, const QString &targetId, int count = 20);
    void loadLocalChatHistory(const QString &type, const QString &targetId, int count = 50);
    void clearChatHistory(const QString &type, const QString &targetId);
      // 离线消息处理
    void processOfflineMessages();
    void clearOfflineMessages();
    
    // 用户登录处理
    void onUserLoggedIn(const QString &userId);

    // 消息管理
    void recallMessage(const QString &messageId, const QString &type, const QString &targetId);
    void markMessageRead(const QString &messageId, const QString &type, const QString &targetId);

signals:
    // 连接状态
    void connectedChanged();
    
    // 消息相关信号
    void privateMessageReceived(const QString &fromUserId, const QString &fromUsername, 
                               const QString &content, const QString &messageId, const QString &timestamp);
    void groupMessageReceived(const QString &groupId, const QString &fromUserId, 
                             const QString &fromUsername, const QString &content, 
                             const QString &messageId, const QString &timestamp);
    
    // 好友相关信号
    void friendsListChanged();
    void friendRequestReceived(const QString &fromUserId, const QString &fromUsername);
    void friendRequestSent(const QString &toUserId);
    void friendRequestAccepted(const QString &userId, const QString &username);
    void friendRequestRejected(const QString &userId);
    void friendAdded(const QString &friendId, const QString &username);
    
    // 群组相关信号
    void groupsListChanged();
    void groupCreated(const QString &groupId, const QString &groupName);
    void joinedGroup(const QString &groupId, const QString &groupName);
    void leftGroup(const QString &groupId);
    void groupMembersReceived(const QString &groupId, const QVariantList &members);
    
    // 用户列表信号
    void usersListChanged();
      // 聊天历史信号
    void chatHistoryReceived(const QString &type, const QString &targetId, const QVariantList &messages);
    void localChatHistoryLoaded(const QString &type, const QString &targetId, const QVariantList &messages);
    void offlineMessagesProcessed(int count);
    
    // 消息状态信号
    void messageRecalled(const QString &messageId, const QString &type, const QString &targetId);
    void messageMarkedRead(const QString &messageId);
    
    // 错误信号
    void errorOccurred(const QString &error);

private slots:
    void handleNetworkMessage(const Message *message);
    void handleNetworkConnected();
    void handleNetworkDisconnected();

private:
    void parseMessage(int messageType, const QVariantMap &data);
    QVariantMap parseMessageContent(const QString &content);
    void initializeChatHistory(const QString &userId);
    
    NetworkManager *m_networkManager;
    ChatHistoryManager *m_chatHistoryManager;
    QString m_currentUserId; // 当前用户ID
    QVariantList m_friendsList;
    QVariantList m_groupsList;
    QVariantList m_usersList;
};
