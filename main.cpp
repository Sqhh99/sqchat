#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>
#include <qqml.h>

// 包含自定义类
#include "include/NetworkManager.h"
#include "include/AuthController.h"
#include "include/ChatController.h"
#include "include/Message.h"
#include "include/MessageType.h"
#include "include/ChatHistoryManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    // 设置Qt Quick样式为Basic，以支持自定义控件
    QQuickStyle::setStyle("Basic");    // 注册QML类型    qmlRegisterType<NetworkManager>("SQChat", 1, 0, "NetworkManager");
    qmlRegisterType<AuthController>("SQChat", 1, 0, "AuthController");
    qmlRegisterType<ChatController>("SQChat", 1, 0, "ChatController");
    qmlRegisterType<Message>("SQChat", 1, 0, "Message");
    qmlRegisterType<ChatHistoryManager>("SQChat", 1, 0, "ChatHistoryManager");
    
    // 注册枚举类型 - MessageType
    qmlRegisterUncreatableMetaObject(
        MessageTypeWrapper::staticMetaObject,
        "SQChat",
        1, 0,
        "MessageType",
        "MessageType is an enum and cannot be created"
    );    // 创建全局单例对象
    NetworkManager* networkManager = new NetworkManager(&app);
    AuthController* authController = new AuthController(&app);
    ChatController* chatController = new ChatController(&app);
    ChatHistoryManager* chatHistoryManager = new ChatHistoryManager(&app);    authController->setNetworkManager(networkManager);
    chatController->setNetworkManager(networkManager);
    chatController->setChatHistoryManager(chatHistoryManager);
    
    // 连接信号：当用户登录成功时初始化聊天历史管理器
    QObject::connect(authController, &AuthController::userLoggedIn,
                     chatController, &ChatController::onUserLoggedIn);

    QQmlApplicationEngine engine;      // 将对象暴露给QML
    engine.rootContext()->setContextProperty("globalNetworkManager", networkManager);
    engine.rootContext()->setContextProperty("globalAuthController", authController);
    engine.rootContext()->setContextProperty("globalChatController", chatController);
    engine.rootContext()->setContextProperty("globalChatHistoryManager", chatHistoryManager);
    
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("sqchat", "Main");

    return app.exec();
}
