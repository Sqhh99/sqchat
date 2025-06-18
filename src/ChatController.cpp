#include "include/ChatController.h"
#include "include/NetworkManager.h"
#include "include/MessageType.h"
#include "include/Message.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

ChatController::ChatController(QObject *parent)
    : QObject(parent)
    , m_networkManager(nullptr)
{
}

void ChatController::setNetworkManager(NetworkManager *manager)
{
    if (m_networkManager) {
        disconnect(m_networkManager, nullptr, this, nullptr);
    }
    
    m_networkManager = manager;
    
    if (m_networkManager) {
        connect(m_networkManager, &NetworkManager::messageReceived, 
                this, &ChatController::handleNetworkMessage);
        connect(m_networkManager, &NetworkManager::connected, 
                this, &ChatController::handleNetworkConnected);
        connect(m_networkManager, &NetworkManager::disconnected, 
                this, &ChatController::handleNetworkDisconnected);
    }
}

bool ChatController::isConnected() const
{
    return m_networkManager && m_networkManager->isConnected();
}

void ChatController::sendPrivateMessage(const QString &toUserId, const QString &content)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["toUserId"] = toUserId;
    data["content"] = content;
    
    m_networkManager->sendMessage(MessageType::PRIVATE_CHAT, data);
    qDebug() << "Private message sent to:" << toUserId << "content:" << content;
}

void ChatController::sendGroupMessage(const QString &groupId, const QString &content)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["groupId"] = groupId;
    data["content"] = content;
    
    m_networkManager->sendMessage(MessageType::GROUP_CHAT, data);
    qDebug() << "Group message sent to group:" << groupId << "content:" << content;
}

void ChatController::getFriendsList()
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data; // 空数据
    m_networkManager->sendMessage(MessageType::GET_USER_FRIENDS, data);
    qDebug() << "Friends list requested";
}

void ChatController::addFriend(const QString &friendId)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["friendId"] = friendId;
    m_networkManager->sendMessage(MessageType::ADD_FRIEND_REQUEST, data);
    qDebug() << "Add friend request sent for:" << friendId;
}

void ChatController::acceptFriendRequest(const QString &fromUserId)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["fromUserId"] = fromUserId;
    m_networkManager->sendMessage(MessageType::ACCEPT_FRIEND_REQUEST, data);
    qDebug() << "Friend request accepted from:" << fromUserId;
}

void ChatController::rejectFriendRequest(const QString &fromUserId)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["fromUserId"] = fromUserId;
    m_networkManager->sendMessage(MessageType::REJECT_FRIEND_REQUEST, data);
    qDebug() << "Friend request rejected from:" << fromUserId;
}

void ChatController::getFriendRequests()
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data; // 空数据
    m_networkManager->sendMessage(MessageType::GET_FRIEND_REQUESTS, data);
    qDebug() << "Friend requests list requested";
}

void ChatController::getGroupsList()
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data; // 空数据
    m_networkManager->sendMessage(MessageType::GET_GROUP_LIST, data);
    qDebug() << "Groups list requested";
}

void ChatController::createGroup(const QString &groupName)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["groupName"] = groupName;
    m_networkManager->sendMessage(MessageType::CREATE_GROUP, data);
    qDebug() << "Create group request sent:" << groupName;
}

void ChatController::joinGroup(const QString &groupId)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["groupId"] = groupId;
    m_networkManager->sendMessage(MessageType::JOIN_GROUP, data);
    qDebug() << "Join group request sent:" << groupId;
}

void ChatController::leaveGroup(const QString &groupId)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["groupId"] = groupId;
    m_networkManager->sendMessage(MessageType::LEAVE_GROUP, data);
    qDebug() << "Leave group request sent:" << groupId;
}

void ChatController::getGroupMembers(const QString &groupId)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["groupId"] = groupId;
    m_networkManager->sendMessage(MessageType::GET_GROUP_MEMBERS, data);
    qDebug() << "Group members requested for group:" << groupId;
}

void ChatController::getUsersList()
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data; // 空数据
    m_networkManager->sendMessage(MessageType::GET_USER_LIST, data);
    qDebug() << "Users list requested";
}

void ChatController::getChatHistory(const QString &type, const QString &targetId, int count)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["type"] = type;
    if (type == "private") {
        data["targetUserId"] = targetId;
    } else if (type == "group") {
        data["groupId"] = targetId;
    }
    data["count"] = QString::number(count);  // 确保count是字符串
    
    m_networkManager->sendMessage(MessageType::GET_CHAT_HISTORY, data);
    qDebug() << "Chat history requested for type:" << type << "target:" << targetId << "count:" << count;
}

void ChatController::recallMessage(const QString &messageId, const QString &type, const QString &targetId)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["messageId"] = messageId;
    data["type"] = type;
    if (type == "private") {
        data["targetUserId"] = targetId;
    } else if (type == "group") {
        data["groupId"] = targetId;
    }
    
    m_networkManager->sendMessage(MessageType::RECALL_MESSAGE, data);
    qDebug() << "Recall message request sent for:" << messageId;
}

void ChatController::markMessageRead(const QString &messageId, const QString &type, const QString &targetId)
{
    if (!m_networkManager || !isConnected()) {
        emit errorOccurred("未连接到服务器");
        return;
    }
    
    QVariantMap data;
    data["messageId"] = messageId;
    data["type"] = type;
    if (type == "private") {
        data["targetUserId"] = targetId;
    } else if (type == "group") {
        data["groupId"] = targetId;
    }
    
    m_networkManager->sendMessage(MessageType::MARK_MESSAGE_READ, data);
    qDebug() << "Mark message read request sent for:" << messageId;
}

void ChatController::handleNetworkMessage(const Message *message)
{
    if (!message) {
        qDebug() << "Received null message";
        return;
    }
    
    MessageType messageType = message->type();
    QVariantMap data = message->data();
    
    parseMessage(static_cast<int>(messageType), data);
}

void ChatController::handleNetworkConnected()
{
    emit connectedChanged();
}

void ChatController::handleNetworkDisconnected()
{
    emit connectedChanged();
}

void ChatController::parseMessage(int messageType, const QVariantMap &data)
{
    switch (static_cast<MessageType>(messageType)) {
        case MessageType::LOGIN_RESPONSE:
            {
                QString status = data["status"].toString();
                if (status == "0") {
                    // 登录成功，无需特殊处理，AuthController会处理
                    qDebug() << "Login response received (success)";
                } else {
                    QString message = data["message"].toString();
                    qDebug() << "Login response received (failed):" << message;
                }
            }
            break;
            
        case MessageType::ERROR:
            {
                QString errorMsg = data.value("errorMsg", data.value("message", "未知错误")).toString();
                emit errorOccurred(errorMsg);
                qDebug() << "Server error:" << errorMsg;
            }
            break;
            
        case MessageType::HEARTBEAT_RESPONSE:
            // 心跳响应，无需特殊处理
            break;
            
        case MessageType::ADD_FRIEND_RESPONSE:
            {
                QString status = data["status"].toString();
                if (status == "0") {
                    QString friendId = data["friendId"].toString();
                    QString username = data["username"].toString();
                    emit friendAdded(friendId, username);
                    qDebug() << "Friend added successfully:" << username;
                } else {
                    QString message = data["message"].toString();
                    emit errorOccurred(QString("添加好友失败: %1").arg(message));
                    qDebug() << "Add friend failed:" << message;
                }
            }
            break;
            
        case MessageType::PRIVATE_CHAT:
            emit privateMessageReceived(
                data["fromUserId"].toString(),
                data["fromUsername"].toString(),
                data["content"].toString(),
                data["messageId"].toString(),
                data["timestamp"].toString()
            );
            break;
            
        case MessageType::GROUP_CHAT:
            emit groupMessageReceived(
                data["groupId"].toString(),
                data["fromUserId"].toString(),
                data["fromUsername"].toString(),
                data["content"].toString(),
                data["messageId"].toString(),
                data["timestamp"].toString()
            );
            break;
            
        case MessageType::ADD_FRIEND_REQUEST:
            emit friendRequestReceived(
                data["fromUserId"].toString(),
                data["fromUsername"].toString()
            );
            break;
              case MessageType::ACCEPT_FRIEND_RESPONSE:
            emit friendRequestAccepted(
                data["userId"].toString(),
                data["username"].toString()
            );
            break;
            
        case MessageType::REJECT_FRIEND_RESPONSE:
            emit friendRequestRejected(data["userId"].toString());
            break;
              case MessageType::USER_FRIENDS_RESPONSE:
            {
                QVariantList friends;
                // 解析服务器返回的好友列表数据
                QString friendsJson = data["friends"].toString();
                QJsonDocument doc = QJsonDocument::fromJson(friendsJson.toUtf8());
                if (doc.isArray()) {
                    QJsonArray array = doc.array();
                    for (const auto &value : array) {
                        if (value.isObject()) {                            QJsonObject obj = value.toObject();
                            QVariantMap friendData;
                            // 处理id字段 - 可能是数字或字符串
                            QJsonValue idValue = obj["id"];
                            QString userId;
                            if (idValue.isDouble()) {
                                userId = QString::number(idValue.toInt());
                            } else {
                                userId = idValue.toString();
                            }
                            friendData["userId"] = userId;
                            friendData["username"] = obj["username"].toString();
                            friendData["online"] = obj["online"].toBool();
                            qDebug() << "Parsed friend:" << userId << obj["username"].toString() << obj["online"].toBool();
                            friends.append(friendData);
                        }
                    }
                }
                m_friendsList = friends;
                emit friendsListChanged();
                qDebug() << "Friends list updated with" << friends.size() << "friends";
            }
            break;
              case MessageType::FRIEND_REQUESTS_RESPONSE:
            // 处理好友请求列表
            break;
            
        case MessageType::GROUP_LIST_RESPONSE:
            {
                QVariantList groups;
                QJsonDocument doc = QJsonDocument::fromJson(data["groups"].toString().toUtf8());
                if (doc.isArray()) {
                    QJsonArray array = doc.array();
                    for (const auto &value : array) {
                        if (value.isObject()) {
                            QJsonObject obj = value.toObject();
                            QVariantMap groupData;
                            groupData["groupId"] = obj["group_id"].toString();
                            groupData["groupName"] = obj["group_name"].toString();
                            groupData["memberCount"] = obj["member_count"].toInt();
                            groups.append(groupData);
                        }
                    }
                }
                m_groupsList = groups;
                emit groupsListChanged();
            }
            break;
              case MessageType::CREATE_GROUP_RESPONSE:
            emit groupCreated(
                data["groupId"].toString(),
                data["groupName"].toString()
            );
            break;
            
        case MessageType::JOIN_GROUP_RESPONSE:
            emit joinedGroup(
                data["groupId"].toString(),
                data["groupName"].toString()
            );
            break;
            
        case MessageType::LEAVE_GROUP_RESPONSE:
            emit leftGroup(data["groupId"].toString());
            break;
            
        case MessageType::GROUP_MEMBERS_RESPONSE:
            {
                QVariantList members;
                QJsonDocument doc = QJsonDocument::fromJson(data["members"].toString().toUtf8());
                if (doc.isArray()) {
                    QJsonArray array = doc.array();
                    for (const auto &value : array) {
                        if (value.isObject()) {
                            QJsonObject obj = value.toObject();
                            QVariantMap memberData;
                            memberData["userId"] = obj["user_id"].toString();
                            memberData["username"] = obj["username"].toString();
                            memberData["role"] = obj["role"].toString();
                            members.append(memberData);
                        }
                    }
                }
                emit groupMembersReceived(data["groupId"].toString(), members);
            }
            break;
              case MessageType::USER_LIST_RESPONSE:
            {
                QVariantList users;
                // 解析服务器返回的用户列表数据
                QString usersJson = data["users"].toString();
                QJsonDocument doc = QJsonDocument::fromJson(usersJson.toUtf8());
                if (doc.isArray()) {
                    QJsonArray array = doc.array();
                    for (const auto &value : array) {
                        if (value.isObject()) {
                            QJsonObject obj = value.toObject();
                            QVariantMap userData;
                            userData["userId"] = obj["id"].toString();
                            userData["username"] = obj["username"].toString();
                            userData["online"] = obj["online"].toBool();
                            users.append(userData);
                        }
                    }
                }
                m_usersList = users;
                emit usersListChanged();
                qDebug() << "Users list updated with" << users.size() << "users";
            }
            break;
            
        case MessageType::CHAT_HISTORY_RESPONSE:
            {
                QVariantList messages;
                QJsonDocument doc = QJsonDocument::fromJson(data["messages"].toString().toUtf8());
                if (doc.isArray()) {
                    QJsonArray array = doc.array();
                    for (const auto &value : array) {
                        if (value.isObject()) {
                            QJsonObject obj = value.toObject();
                            QVariantMap messageData;
                            messageData["messageId"] = obj["message_id"].toString();
                            messageData["fromUserId"] = obj["from_user_id"].toString();
                            messageData["fromUsername"] = obj["from_username"].toString();
                            messageData["content"] = obj["content"].toString();
                            messageData["timestamp"] = obj["timestamp"].toString();
                            messages.append(messageData);
                        }
                    }
                }
                emit chatHistoryReceived(
                    data["type"].toString(),
                    data["targetId"].toString(),
                    messages
                );
            }
            break;
              case MessageType::RECALL_MESSAGE_RESPONSE:
            emit messageRecalled(
                data["messageId"].toString(),
                data["type"].toString(),
                data["targetId"].toString()
            );
            break;
            
        case MessageType::MARK_MESSAGE_READ_RESPONSE:
            emit messageMarkedRead(data["messageId"].toString());
            break;
            
        default:
            qDebug() << "Unknown message type:" << messageType;
            break;
    }
}

QVariantMap ChatController::parseMessageContent(const QString &content)
{
    QVariantMap data;
    
    if (content.isEmpty()) {
        return data;
    }
    
    QStringList pairs = content.split(QStringLiteral(";"), Qt::SkipEmptyParts);
    for (const QString &pair : pairs) {
        QStringList keyValue = pair.split(QStringLiteral("="), Qt::KeepEmptyParts);
        if (keyValue.size() == 2) {
            data[keyValue[0]] = keyValue[1];
        }
    }
    
    return data;
}
