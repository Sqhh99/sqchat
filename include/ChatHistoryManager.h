#ifndef CHATHISTORYMANAGER_H
#define CHATHISTORYMANAGER_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDir>
#include <QStandardPaths>
#include <QDateTime>
#include <memory>
#include "Message.h"

/**
 * @brief 聊天历史管理器
 * 负责聊天记录的本地JSON文件存储和读取
 * 支持私聊和群聊记录的分别管理
 */
class ChatHistoryManager : public QObject
{
    Q_OBJECT

public:
    explicit ChatHistoryManager(QObject *parent = nullptr);
    ~ChatHistoryManager();

    // 初始化管理器
    bool initialize(const QString &userId);
      // 设置当前用户ID
    void setCurrentUserId(const QString &userId);
    Q_INVOKABLE QString getCurrentUserId() const { return m_currentUserId; }

public slots:
    // 消息存储
    void savePrivateMessage(const QString &fromUserId, const QString &toUserId, 
                          const QString &content, const QString &messageId = "",
                          qint64 timestamp = 0);
    void saveGroupMessage(const QString &groupId, const QString &fromUserId,
                         const QString &content, const QString &messageId = "",
                         qint64 timestamp = 0);
    
    // 消息读取
    QJsonArray getPrivateMessages(const QString &otherUserId, int count = 50, int offset = 0);
    QJsonArray getGroupMessages(const QString &groupId, int count = 50, int offset = 0);
    
    // 消息操作
    void markMessageAsRead(const QString &messageId, const QString &chatId, bool isGroup = false);
    void recallMessage(const QString &messageId, const QString &chatId, bool isGroup = false);
    
    // 离线消息处理
    void saveOfflineMessage(const QJsonObject &messageData);
    QJsonArray getOfflineMessages();
    void clearOfflineMessages();
    
    // 获取聊天列表
    QJsonArray getRecentChats(int count = 20);
    
    // 清理操作
    void clearChatHistory(const QString &chatId, bool isGroup = false);
    void clearAllHistory();

signals:
    void messagesSaved();
    void messagesLoaded(const QJsonArray &messages);
    void offlineMessagesAvailable(int count);

private:
    QString m_currentUserId;
    QString m_dataDir;
    QString m_userDataDir;
    
    // 文件路径管理
    QString getPrivateChatFilePath(const QString &otherUserId) const;
    QString getGroupChatFilePath(const QString &groupId) const;
    QString getOfflineMessagesFilePath() const;
    QString getRecentChatsFilePath() const;
    
    // JSON文件操作
    QJsonArray loadJsonArray(const QString &filePath) const;
    bool saveJsonArray(const QString &filePath, const QJsonArray &array);
    QJsonObject loadJsonObject(const QString &filePath) const;
    bool saveJsonObject(const QString &filePath, const QJsonObject &object);
    
    // 消息处理
    QJsonObject createMessageObject(const QString &fromUserId, const QString &content,
                                  const QString &messageId, qint64 timestamp) const;
    void updateRecentChats(const QString &chatId, const QString &chatName, 
                          const QString &lastMessage, bool isGroup = false);
    
    // 文件系统操作
    bool ensureDirectoryExists(const QString &dirPath);
    void initializeDataDirectory();
};

#endif // CHATHISTORYMANAGER_H
