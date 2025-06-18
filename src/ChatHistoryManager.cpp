#include "include/ChatHistoryManager.h"
#include <QDebug>
#include <QFile>
#include <QJsonParseError>

ChatHistoryManager::ChatHistoryManager(QObject *parent)
    : QObject(parent)
{
    // 初始化数据目录
    initializeDataDirectory();
}

ChatHistoryManager::~ChatHistoryManager()
{
}

void ChatHistoryManager::initializeDataDirectory()
{
    // 使用应用程序数据目录
    m_dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    
    // 确保基础目录存在
    ensureDirectoryExists(m_dataDir);
}

bool ChatHistoryManager::initialize(const QString &userId)
{
    if (userId.isEmpty()) {
        qWarning() << "用户ID不能为空";
        return false;
    }
    
    setCurrentUserId(userId);
      // 创建用户专用数据目录
    m_userDataDir = QDir(m_dataDir).filePath(userId);
    qDebug() << "数据目录路径:" << m_dataDir;
    qDebug() << "用户数据目录路径:" << m_userDataDir;
    
    if (!ensureDirectoryExists(m_userDataDir)) {
        qWarning() << "无法创建用户数据目录:" << m_userDataDir;
        return false;
    }
    
    // 创建子目录
    QString privateChatsDir = QDir(m_userDataDir).filePath("private_chats");
    QString groupChatsDir = QDir(m_userDataDir).filePath("group_chats");
    
    qDebug() << "私聊目录:" << privateChatsDir;
    qDebug() << "群聊目录:" << groupChatsDir;
    
    ensureDirectoryExists(privateChatsDir);
    ensureDirectoryExists(groupChatsDir);
    
    qDebug() << "聊天历史管理器初始化成功，用户:" << userId;
    
    // 检查是否有离线消息
    QJsonArray offlineMessages = getOfflineMessages();
    if (!offlineMessages.isEmpty()) {
        emit offlineMessagesAvailable(offlineMessages.size());
    }
    
    return true;
}

void ChatHistoryManager::setCurrentUserId(const QString &userId)
{
    m_currentUserId = userId;
}

void ChatHistoryManager::savePrivateMessage(const QString &fromUserId, const QString &toUserId, 
                                          const QString &content, const QString &messageId,
                                          qint64 timestamp)
{
    if (m_currentUserId.isEmpty()) {
        qWarning() << "当前用户ID为空，无法保存消息";
        return;
    }
    
    // 确定对话的另一方
    QString otherUserId = (fromUserId == m_currentUserId) ? toUserId : fromUserId;
      // 获取文件路径
    QString filePath = getPrivateChatFilePath(otherUserId);
    qDebug() << "保存私聊消息到文件:" << filePath;
    
    // 加载现有消息
    QJsonArray messages = loadJsonArray(filePath);
    qDebug() << "当前文件中的消息数量:" << messages.size();
    
    // 创建新消息对象
    QJsonObject messageObj = createMessageObject(fromUserId, content, messageId, timestamp);
    messageObj["toUserId"] = toUserId;
    messageObj["type"] = "private";
    
    // 添加到消息数组
    messages.append(messageObj);
    qDebug() << "添加消息后的总数量:" << messages.size();
    
    // 保存到文件
    if (saveJsonArray(filePath, messages)) {
        qDebug() << "私聊消息已保存:" << fromUserId << "->" << toUserId;
        
        // 更新最近聊天列表
        QString chatName = otherUserId; // 这里可以后续优化为显示用户名
        updateRecentChats(otherUserId, chatName, content, false);
        
        emit messagesSaved();
    } else {
        qWarning() << "保存私聊消息失败";
    }
}

void ChatHistoryManager::saveGroupMessage(const QString &groupId, const QString &fromUserId,
                                        const QString &content, const QString &messageId,
                                        qint64 timestamp)
{
    if (m_currentUserId.isEmpty()) {
        qWarning() << "当前用户ID为空，无法保存消息";
        return;
    }
    
    // 获取文件路径
    QString filePath = getGroupChatFilePath(groupId);
    
    // 加载现有消息
    QJsonArray messages = loadJsonArray(filePath);
    
    // 创建新消息对象
    QJsonObject messageObj = createMessageObject(fromUserId, content, messageId, timestamp);
    messageObj["groupId"] = groupId;
    messageObj["type"] = "group";
    
    // 添加到消息数组
    messages.append(messageObj);
    
    // 保存到文件
    if (saveJsonArray(filePath, messages)) {
        qDebug() << "群聊消息已保存:" << groupId << "，来自:" << fromUserId;
        
        // 更新最近聊天列表
        QString chatName = "群聊 " + groupId; // 这里可以后续优化为显示群名
        updateRecentChats(groupId, chatName, content, true);
        
        emit messagesSaved();
    } else {
        qWarning() << "保存群聊消息失败";
    }
}

QJsonArray ChatHistoryManager::getPrivateMessages(const QString &otherUserId, int count, int offset)
{
    QString filePath = getPrivateChatFilePath(otherUserId);
    qDebug() << "加载私聊消息从文件:" << filePath;
    
    QJsonArray allMessages = loadJsonArray(filePath);
    qDebug() << "文件中总消息数量:" << allMessages.size();
    
    // 应用分页
    QJsonArray result;
    int start = qMax(0, allMessages.size() - count - offset);
    int end = qMax(0, allMessages.size() - offset);
    
    qDebug() << "分页参数 - start:" << start << "end:" << end << "count:" << count << "offset:" << offset;
    
    for (int i = start; i < end; ++i) {
        result.append(allMessages[i]);
    }
    
    qDebug() << "返回消息数量:" << result.size();
    return result;
}

QJsonArray ChatHistoryManager::getGroupMessages(const QString &groupId, int count, int offset)
{
    QString filePath = getGroupChatFilePath(groupId);
    QJsonArray allMessages = loadJsonArray(filePath);
    
    // 应用分页
    QJsonArray result;
    int start = qMax(0, allMessages.size() - count - offset);
    int end = qMax(0, allMessages.size() - offset);
    
    for (int i = start; i < end; ++i) {
        result.append(allMessages[i]);
    }
    
    return result;
}

void ChatHistoryManager::markMessageAsRead(const QString &messageId, const QString &chatId, bool isGroup)
{
    QString filePath = isGroup ? getGroupChatFilePath(chatId) : getPrivateChatFilePath(chatId);
    QJsonArray messages = loadJsonArray(filePath);
    
    bool found = false;
    for (int i = 0; i < messages.size(); ++i) {
        QJsonObject msg = messages[i].toObject();
        if (msg["messageId"].toString() == messageId) {
            msg["isRead"] = true;
            messages[i] = msg;
            found = true;
            break;
        }
    }
    
    if (found) {
        saveJsonArray(filePath, messages);
        qDebug() << "消息已标记为已读:" << messageId;
    }
}

void ChatHistoryManager::recallMessage(const QString &messageId, const QString &chatId, bool isGroup)
{
    QString filePath = isGroup ? getGroupChatFilePath(chatId) : getPrivateChatFilePath(chatId);
    QJsonArray messages = loadJsonArray(filePath);
    
    bool found = false;
    for (int i = 0; i < messages.size(); ++i) {
        QJsonObject msg = messages[i].toObject();
        if (msg["messageId"].toString() == messageId) {
            msg["recalled"] = true;
            msg["content"] = "[消息已撤回]";
            messages[i] = msg;
            found = true;
            break;
        }
    }
    
    if (found) {
        saveJsonArray(filePath, messages);
        qDebug() << "消息已撤回:" << messageId;
    }
}

void ChatHistoryManager::saveOfflineMessage(const QJsonObject &messageData)
{
    QString filePath = getOfflineMessagesFilePath();
    QJsonArray offlineMessages = loadJsonArray(filePath);
    
    // 添加时间戳
    QJsonObject msgObj = messageData;
    msgObj["receivedAt"] = QDateTime::currentMSecsSinceEpoch();
    
    offlineMessages.append(msgObj);
    
    if (saveJsonArray(filePath, offlineMessages)) {
        qDebug() << "离线消息已保存";
    }
}

QJsonArray ChatHistoryManager::getOfflineMessages()
{
    QString filePath = getOfflineMessagesFilePath();
    return loadJsonArray(filePath);
}

void ChatHistoryManager::clearOfflineMessages()
{
    QString filePath = getOfflineMessagesFilePath();
    QJsonArray emptyArray;
    saveJsonArray(filePath, emptyArray);
    qDebug() << "离线消息已清空";
}

QJsonArray ChatHistoryManager::getRecentChats(int count)
{
    QString filePath = getRecentChatsFilePath();
    QJsonObject recentChatsObj = loadJsonObject(filePath);
    QJsonArray chats = recentChatsObj["chats"].toArray();
    
    // 按最后消息时间排序并限制数量
    QJsonArray result;
    int actualCount = qMin(count, chats.size());
    for (int i = 0; i < actualCount; ++i) {
        result.append(chats[i]);
    }
    
    return result;
}

void ChatHistoryManager::clearChatHistory(const QString &chatId, bool isGroup)
{
    QString filePath = isGroup ? getGroupChatFilePath(chatId) : getPrivateChatFilePath(chatId);
    QJsonArray emptyArray;
    saveJsonArray(filePath, emptyArray);
    qDebug() << "聊天记录已清空:" << chatId;
}

void ChatHistoryManager::clearAllHistory()
{
    // 清空所有聊天文件夹
    QDir privateChatsDir(QDir(m_userDataDir).filePath("private_chats"));
    QDir groupChatsDir(QDir(m_userDataDir).filePath("group_chats"));
    
    // 删除所有私聊文件
    QStringList privateFiles = privateChatsDir.entryList(QStringList() << "*.json", QDir::Files);
    for (const QString &fileName : privateFiles) {
        privateChatsDir.remove(fileName);
    }
    
    // 删除所有群聊文件
    QStringList groupFiles = groupChatsDir.entryList(QStringList() << "*.json", QDir::Files);
    for (const QString &fileName : groupFiles) {
        groupChatsDir.remove(fileName);
    }
    
    // 清空最近聊天
    QJsonObject emptyObj;
    emptyObj["chats"] = QJsonArray();
    saveJsonObject(getRecentChatsFilePath(), emptyObj);
    
    qDebug() << "所有聊天记录已清空";
}

// 私有方法实现

QString ChatHistoryManager::getPrivateChatFilePath(const QString &otherUserId) const
{
    return QDir(m_userDataDir).filePath(QString("private_chats/%1.json").arg(otherUserId));
}

QString ChatHistoryManager::getGroupChatFilePath(const QString &groupId) const
{
    return QDir(m_userDataDir).filePath(QString("group_chats/group_%1.json").arg(groupId));
}

QString ChatHistoryManager::getOfflineMessagesFilePath() const
{
    return QDir(m_userDataDir).filePath("offline_messages.json");
}

QString ChatHistoryManager::getRecentChatsFilePath() const
{
    return QDir(m_userDataDir).filePath("recent_chats.json");
}

QJsonArray ChatHistoryManager::loadJsonArray(const QString &filePath) const
{
    qDebug() << "尝试加载JSON数组文件:" << filePath;
    
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "文件不存在或无法打开:" << filePath;
        return QJsonArray(); // 返回空数组
    }
    
    QByteArray data = file.readAll();
    qDebug() << "文件大小:" << data.size() << "字节";
    
    if (data.isEmpty()) {
        qDebug() << "文件为空:" << filePath;
        return QJsonArray();
    }
    
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "解析JSON文件失败:" << filePath << error.errorString();
        return QJsonArray();
    }
    
    QJsonArray result = doc.array();
    qDebug() << "成功加载JSON数组，元素数量:" << result.size();
    return result;
}

bool ChatHistoryManager::saveJsonArray(const QString &filePath, const QJsonArray &array)
{
    // 确保目录存在
    QFileInfo fileInfo(filePath);
    ensureDirectoryExists(fileInfo.absolutePath());
    
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "无法写入文件:" << filePath;
        return false;
    }
    
    QJsonDocument doc(array);
    file.write(doc.toJson());
    return true;
}

QJsonObject ChatHistoryManager::loadJsonObject(const QString &filePath) const
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        return QJsonObject(); // 返回空对象
    }
    
    QByteArray data = file.readAll();
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "解析JSON文件失败:" << filePath << error.errorString();
        return QJsonObject();
    }
    
    return doc.object();
}

bool ChatHistoryManager::saveJsonObject(const QString &filePath, const QJsonObject &object)
{
    // 确保目录存在
    QFileInfo fileInfo(filePath);
    ensureDirectoryExists(fileInfo.absolutePath());
    
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "无法写入文件:" << filePath;
        return false;
    }
    
    QJsonDocument doc(object);
    file.write(doc.toJson());
    return true;
}

QJsonObject ChatHistoryManager::createMessageObject(const QString &fromUserId, const QString &content,
                                                   const QString &messageId, qint64 timestamp) const
{
    QJsonObject messageObj;
    messageObj["fromUserId"] = fromUserId;
    messageObj["content"] = content;
    messageObj["messageId"] = messageId.isEmpty() ? QString::number(QDateTime::currentMSecsSinceEpoch()) : messageId;
    messageObj["timestamp"] = timestamp == 0 ? QDateTime::currentMSecsSinceEpoch() : timestamp;
    messageObj["isRead"] = false;
    messageObj["recalled"] = false;
    
    return messageObj;
}

void ChatHistoryManager::updateRecentChats(const QString &chatId, const QString &chatName, 
                                         const QString &lastMessage, bool isGroup)
{
    QString filePath = getRecentChatsFilePath();
    QJsonObject recentChatsObj = loadJsonObject(filePath);
    QJsonArray chats = recentChatsObj.value("chats").toArray();
    
    // 查找是否已存在此聊天
    int existingIndex = -1;
    for (int i = 0; i < chats.size(); ++i) {
        QJsonObject chat = chats[i].toObject();
        if (chat["chatId"].toString() == chatId && chat["isGroup"].toBool() == isGroup) {
            existingIndex = i;
            break;
        }
    }
    
    // 创建或更新聊天对象
    QJsonObject chatObj;
    chatObj["chatId"] = chatId;
    chatObj["chatName"] = chatName;
    chatObj["lastMessage"] = lastMessage;
    chatObj["lastMessageTime"] = QDateTime::currentMSecsSinceEpoch();
    chatObj["isGroup"] = isGroup;
    chatObj["unreadCount"] = 0; // 这里可以后续实现未读计数
    
    if (existingIndex >= 0) {
        // 更新现有聊天
        chats[existingIndex] = chatObj;
    } else {
        // 添加新聊天到开头
        chats.prepend(chatObj);
    }
    
    // 限制最近聊天数量
    while (chats.size() > 50) {
        chats.removeLast();
    }
    
    recentChatsObj["chats"] = chats;
    saveJsonObject(filePath, recentChatsObj);
}

bool ChatHistoryManager::ensureDirectoryExists(const QString &dirPath)
{
    QDir dir;
    if (!dir.exists(dirPath)) {
        return dir.mkpath(dirPath);
    }
    return true;
}
