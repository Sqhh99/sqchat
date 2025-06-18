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

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    // 设置Qt Quick样式为Basic，以支持自定义控件
    QQuickStyle::setStyle("Basic");    // 注册QML类型    qmlRegisterType<NetworkManager>("SQChat", 1, 0, "NetworkManager");
    qmlRegisterType<AuthController>("SQChat", 1, 0, "AuthController");
    qmlRegisterType<ChatController>("SQChat", 1, 0, "ChatController");
    qmlRegisterType<Message>("SQChat", 1, 0, "Message");
    
    // 注册枚举类型 - MessageType
    qmlRegisterUncreatableMetaObject(
        MessageTypeWrapper::staticMetaObject,
        "SQChat",
        1, 0,
        "MessageType",
        "MessageType is an enum and cannot be created"
    );// 创建全局单例对象
    NetworkManager* networkManager = new NetworkManager(&app);
    AuthController* authController = new AuthController(&app);
    ChatController* chatController = new ChatController(&app);
    authController->setNetworkManager(networkManager);
    chatController->setNetworkManager(networkManager);

    QQmlApplicationEngine engine;
      // 将对象暴露给QML
    engine.rootContext()->setContextProperty("globalNetworkManager", networkManager);
    engine.rootContext()->setContextProperty("globalAuthController", authController);
    engine.rootContext()->setContextProperty("globalChatController", chatController);
    
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("sqchat", "Main");

    return app.exec();
}
