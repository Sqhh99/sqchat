#include <QCoreApplication>
#include <QTcpSocket>
#include <QHostAddress>
#include <QDebug>
#include <QDateTime>
#include <QTimer>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    
    QTcpSocket socket;
    
    // 设置优化选项
    socket.setSocketOption(QAbstractSocket::LowDelayOption, 1);
    
    auto startTime = QDateTime::currentMSecsSinceEpoch();
    
    QObject::connect(&socket, &QTcpSocket::connected, [&startTime]() {
        auto endTime = QDateTime::currentMSecsSinceEpoch();
        qDebug() << "Connected in" << (endTime - startTime) << "ms";
        QCoreApplication::quit();
    });
    
    QObject::connect(&socket, QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::errorOccurred),
                     [](QAbstractSocket::SocketError error) {
        qDebug() << "Connection error:" << error;
        QCoreApplication::quit();
    });
    
    qDebug() << "Connecting to 127.0.0.1:8888...";
    socket.connectToHost(QHostAddress("127.0.0.1"), 8888);
    
    // 设置5秒超时
    QTimer::singleShot(5000, []() {
        qDebug() << "Connection timeout";
        QCoreApplication::quit();
    });
    
    return app.exec();
}
