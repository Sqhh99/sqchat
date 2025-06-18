#ifndef MESSAGETYPE_H
#define MESSAGETYPE_H

#include <QObject>
#include <QQmlEngine>

/**
 * @brief 消息类型枚举
 * 定义客户端和服务器之间通信的消息类型
 * 与服务器端保持一致
 */
enum class MessageType : int {
    LOGIN_REQUEST = 1,              // 登录请求
    LOGIN_RESPONSE = 2,             // 登录响应
    LOGOUT_REQUEST = 3,             // 登出请求
    LOGOUT_RESPONSE = 4,            // 登出响应
    ERROR = 5,                      // 错误消息
    HEARTBEAT_REQUEST = 6,          // 心跳请求
    HEARTBEAT_RESPONSE = 7,         // 心跳响应
    REGISTER_REQUEST = 8,           // 注册请求
    REGISTER_RESPONSE = 9,          // 注册响应
    VERIFY_CODE_REQUEST = 10,       // 验证码请求
    VERIFY_CODE_RESPONSE = 11,      // 验证码响应
    PRIVATE_CHAT = 12,              // 私聊消息
    GROUP_CHAT = 13,                // 群聊消息
    CREATE_GROUP = 14,              // 创建群组
    CREATE_GROUP_RESPONSE = 15,     // 创建群组响应
    JOIN_GROUP = 16,                // 加入群组
    JOIN_GROUP_RESPONSE = 17,       // 加入群组响应
    LEAVE_GROUP = 18,               // 离开群组
    LEAVE_GROUP_RESPONSE = 19,      // 离开群组响应
    GET_USER_LIST = 20,             // 获取用户列表
    USER_LIST_RESPONSE = 21,        // 用户列表响应
    GET_GROUP_LIST = 22,            // 获取群组列表
    GROUP_LIST_RESPONSE = 23,       // 群组列表响应
    GET_GROUP_MEMBERS = 24,         // 获取群成员
    GROUP_MEMBERS_RESPONSE = 25,    // 群成员响应    
    GET_USER_FRIENDS = 26,          // 获取好友列表
    USER_FRIENDS_RESPONSE = 27,     // 好友列表响应
    ADD_FRIEND_REQUEST = 28,        // 发送好友请求
    ADD_FRIEND_RESPONSE = 29,       // 好友请求响应
    GET_CHAT_HISTORY = 30,          // 获取聊天记录
    CHAT_HISTORY_RESPONSE = 31,     // 聊天记录响应
    RECALL_MESSAGE = 32,            // 撤回消息
    RECALL_MESSAGE_RESPONSE = 33,   // 撤回消息响应
    MARK_MESSAGE_READ = 34,         // 标记消息已读
    MARK_MESSAGE_READ_RESPONSE = 35, // 标记消息已读响应
    ACCEPT_FRIEND_REQUEST = 36,     // 接受好友请求
    ACCEPT_FRIEND_RESPONSE = 37,    // 接受好友请求响应
    REJECT_FRIEND_REQUEST = 38,     // 拒绝好友请求
    REJECT_FRIEND_RESPONSE = 39,    // 拒绝好友请求响应    
    GET_FRIEND_REQUESTS = 40,       // 获取好友请求列表
    FRIEND_REQUESTS_RESPONSE = 41,  // 好友请求列表响应
    GET_CHAT_HISTORY_OLD = 42,      // 旧的获取聊天记录（废弃）
    CHAT_HISTORY_RESPONSE_OLD = 43, // 旧的聊天记录响应（废弃）
    RECALL_MESSAGE_OLD = 44,        // 旧的撤回消息（废弃）
    RECALL_MESSAGE_RESPONSE_OLD = 45, // 旧的撤回消息响应（废弃）
    MARK_MESSAGE_READ_OLD = 46,     // 旧的标记消息已读（废弃）
    MARK_MESSAGE_READ_RESPONSE_OLD = 47, // 旧的标记消息已读响应（废弃）
    FILE_MESSAGE = 48,              // 文件消息
    FILE_MESSAGE_RESPONSE = 49,     // 文件消息响应
    IMAGE_MESSAGE = 50,             // 图片消息
    IMAGE_MESSAGE_RESPONSE = 51     // 图片消息响应
};

/**
 * @brief MessageType QML包装类
 * 用于在QML中使用MessageType枚举
 */
class MessageTypeWrapper : public QObject
{
    Q_OBJECT

public:
    enum Type {
        LoginRequest = static_cast<int>(MessageType::LOGIN_REQUEST),
        LoginResponse = static_cast<int>(MessageType::LOGIN_RESPONSE),
        LogoutRequest = static_cast<int>(MessageType::LOGOUT_REQUEST),
        LogoutResponse = static_cast<int>(MessageType::LOGOUT_RESPONSE),
        Error = static_cast<int>(MessageType::ERROR),
        HeartbeatRequest = static_cast<int>(MessageType::HEARTBEAT_REQUEST),
        HeartbeatResponse = static_cast<int>(MessageType::HEARTBEAT_RESPONSE),
        RegisterRequest = static_cast<int>(MessageType::REGISTER_REQUEST),
        RegisterResponse = static_cast<int>(MessageType::REGISTER_RESPONSE),
        VerifyCodeRequest = static_cast<int>(MessageType::VERIFY_CODE_REQUEST),
        VerifyCodeResponse = static_cast<int>(MessageType::VERIFY_CODE_RESPONSE),
        PrivateChat = static_cast<int>(MessageType::PRIVATE_CHAT),
        GroupChat = static_cast<int>(MessageType::GROUP_CHAT),
        CreateGroup = static_cast<int>(MessageType::CREATE_GROUP),
        CreateGroupResponse = static_cast<int>(MessageType::CREATE_GROUP_RESPONSE),
        JoinGroup = static_cast<int>(MessageType::JOIN_GROUP),
        JoinGroupResponse = static_cast<int>(MessageType::JOIN_GROUP_RESPONSE),
        LeaveGroup = static_cast<int>(MessageType::LEAVE_GROUP),
        LeaveGroupResponse = static_cast<int>(MessageType::LEAVE_GROUP_RESPONSE),
        GetUserList = static_cast<int>(MessageType::GET_USER_LIST),
        UserListResponse = static_cast<int>(MessageType::USER_LIST_RESPONSE),
        GetGroupList = static_cast<int>(MessageType::GET_GROUP_LIST),
        GroupListResponse = static_cast<int>(MessageType::GROUP_LIST_RESPONSE),
        GetGroupMembers = static_cast<int>(MessageType::GET_GROUP_MEMBERS),
        GroupMembersResponse = static_cast<int>(MessageType::GROUP_MEMBERS_RESPONSE),
        GetUserFriends = static_cast<int>(MessageType::GET_USER_FRIENDS),
        UserFriendsResponse = static_cast<int>(MessageType::USER_FRIENDS_RESPONSE),
        AddFriendRequest = static_cast<int>(MessageType::ADD_FRIEND_REQUEST),
        AddFriendResponse = static_cast<int>(MessageType::ADD_FRIEND_RESPONSE),
        GetChatHistory = static_cast<int>(MessageType::GET_CHAT_HISTORY),
        ChatHistoryResponse = static_cast<int>(MessageType::CHAT_HISTORY_RESPONSE),
        RecallMessage = static_cast<int>(MessageType::RECALL_MESSAGE),
        RecallMessageResponse = static_cast<int>(MessageType::RECALL_MESSAGE_RESPONSE),
        MarkMessageRead = static_cast<int>(MessageType::MARK_MESSAGE_READ),
        MarkMessageReadResponse = static_cast<int>(MessageType::MARK_MESSAGE_READ_RESPONSE),
        AcceptFriendRequest = static_cast<int>(MessageType::ACCEPT_FRIEND_REQUEST),
        AcceptFriendResponse = static_cast<int>(MessageType::ACCEPT_FRIEND_RESPONSE),
        RejectFriendRequest = static_cast<int>(MessageType::REJECT_FRIEND_REQUEST),
        RejectFriendResponse = static_cast<int>(MessageType::REJECT_FRIEND_RESPONSE),
        GetFriendRequests = static_cast<int>(MessageType::GET_FRIEND_REQUESTS),
        FriendRequestsResponse = static_cast<int>(MessageType::FRIEND_REQUESTS_RESPONSE),
        FileMessage = static_cast<int>(MessageType::FILE_MESSAGE),
        FileMessageResponse = static_cast<int>(MessageType::FILE_MESSAGE_RESPONSE),
        ImageMessage = static_cast<int>(MessageType::IMAGE_MESSAGE),
        ImageMessageResponse = static_cast<int>(MessageType::IMAGE_MESSAGE_RESPONSE)
    };
    Q_ENUM(Type)

    explicit MessageTypeWrapper(QObject *parent = nullptr) : QObject(parent) {}
};

/**
 * @brief 将MessageType转换为字符串
 */
inline QString messageTypeToString(MessageType type) {
    switch (type) {
        case MessageType::LOGIN_REQUEST: return "LOGIN_REQUEST";
        case MessageType::LOGIN_RESPONSE: return "LOGIN_RESPONSE";
        case MessageType::LOGOUT_REQUEST: return "LOGOUT_REQUEST";
        case MessageType::LOGOUT_RESPONSE: return "LOGOUT_RESPONSE";
        case MessageType::ERROR: return "ERROR";
        case MessageType::HEARTBEAT_REQUEST: return "HEARTBEAT_REQUEST";
        case MessageType::HEARTBEAT_RESPONSE: return "HEARTBEAT_RESPONSE";
        case MessageType::REGISTER_REQUEST: return "REGISTER_REQUEST";
        case MessageType::REGISTER_RESPONSE: return "REGISTER_RESPONSE";
        case MessageType::VERIFY_CODE_REQUEST: return "VERIFY_CODE_REQUEST";
        case MessageType::VERIFY_CODE_RESPONSE: return "VERIFY_CODE_RESPONSE";
        case MessageType::PRIVATE_CHAT: return "PRIVATE_CHAT";
        case MessageType::GROUP_CHAT: return "GROUP_CHAT";
        case MessageType::CREATE_GROUP: return "CREATE_GROUP";
        case MessageType::CREATE_GROUP_RESPONSE: return "CREATE_GROUP_RESPONSE";
        case MessageType::JOIN_GROUP: return "JOIN_GROUP";
        case MessageType::JOIN_GROUP_RESPONSE: return "JOIN_GROUP_RESPONSE";
        case MessageType::LEAVE_GROUP: return "LEAVE_GROUP";
        case MessageType::LEAVE_GROUP_RESPONSE: return "LEAVE_GROUP_RESPONSE";
        case MessageType::GET_USER_LIST: return "GET_USER_LIST";
        case MessageType::USER_LIST_RESPONSE: return "USER_LIST_RESPONSE";
        case MessageType::GET_GROUP_LIST: return "GET_GROUP_LIST";
        case MessageType::GROUP_LIST_RESPONSE: return "GROUP_LIST_RESPONSE";
        case MessageType::GET_GROUP_MEMBERS: return "GET_GROUP_MEMBERS";
        case MessageType::GROUP_MEMBERS_RESPONSE: return "GROUP_MEMBERS_RESPONSE";
        case MessageType::GET_USER_FRIENDS: return "GET_USER_FRIENDS";
        case MessageType::USER_FRIENDS_RESPONSE: return "USER_FRIENDS_RESPONSE";
        case MessageType::ADD_FRIEND_REQUEST: return "ADD_FRIEND_REQUEST";
        case MessageType::ADD_FRIEND_RESPONSE: return "ADD_FRIEND_RESPONSE";
        case MessageType::GET_CHAT_HISTORY: return "GET_CHAT_HISTORY";
        case MessageType::CHAT_HISTORY_RESPONSE: return "CHAT_HISTORY_RESPONSE";
        case MessageType::RECALL_MESSAGE: return "RECALL_MESSAGE";
        case MessageType::RECALL_MESSAGE_RESPONSE: return "RECALL_MESSAGE_RESPONSE";
        case MessageType::MARK_MESSAGE_READ: return "MARK_MESSAGE_READ";
        case MessageType::MARK_MESSAGE_READ_RESPONSE: return "MARK_MESSAGE_READ_RESPONSE";
        case MessageType::ACCEPT_FRIEND_REQUEST: return "ACCEPT_FRIEND_REQUEST";
        case MessageType::ACCEPT_FRIEND_RESPONSE: return "ACCEPT_FRIEND_RESPONSE";
        case MessageType::REJECT_FRIEND_REQUEST: return "REJECT_FRIEND_REQUEST";
        case MessageType::REJECT_FRIEND_RESPONSE: return "REJECT_FRIEND_RESPONSE";
        case MessageType::GET_FRIEND_REQUESTS: return "GET_FRIEND_REQUESTS";
        case MessageType::FRIEND_REQUESTS_RESPONSE: return "FRIEND_REQUESTS_RESPONSE";
        case MessageType::FILE_MESSAGE: return "FILE_MESSAGE";
        case MessageType::FILE_MESSAGE_RESPONSE: return "FILE_MESSAGE_RESPONSE";
        case MessageType::IMAGE_MESSAGE: return "IMAGE_MESSAGE";
        case MessageType::IMAGE_MESSAGE_RESPONSE: return "IMAGE_MESSAGE_RESPONSE";
    }
    return "UNKNOWN";
}

#endif // MESSAGETYPE_H
