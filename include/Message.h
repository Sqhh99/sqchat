#ifndef MESSAGE_H
#define MESSAGE_H

#include <QObject>
#include <QVariantMap>
#include <QString>
#include <QDateTime>
#include "MessageType.h"

/**
 * @brief 消息类
 * 封装客户端和服务器之间的消息数据
 */
class Message : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MessageType type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QVariantMap data READ data WRITE setData NOTIFY dataChanged)
    Q_PROPERTY(QDateTime timestamp READ timestamp WRITE setTimestamp NOTIFY timestampChanged)

public:
    explicit Message(QObject *parent = nullptr);
    Message(MessageType type, const QVariantMap &data, QObject *parent = nullptr);
    
    // Getter 和 Setter
    MessageType type() const { return m_type; }
    void setType(MessageType type);
    
    QVariantMap data() const { return m_data; }
    void setData(const QVariantMap &data);
    
    QDateTime timestamp() const { return m_timestamp; }
    void setTimestamp(const QDateTime &timestamp);
    
    // 序列化和反序列化
    QString toString() const;
    static Message* fromString(const QString &messageString, QObject *parent = nullptr);
    
    // 便捷方法
    void setData(const QString &key, const QVariant &value);
    QVariant getData(const QString &key, const QVariant &defaultValue = QVariant()) const;
    
signals:
    void typeChanged();
    void dataChanged();
    void timestampChanged();
    
private:
    MessageType m_type;
    QVariantMap m_data;
    QDateTime m_timestamp;
    
    // 解析消息字符串中的数据部分
    static QVariantMap parseDataString(const QString &dataString);
    
    // 将数据转换为字符串格式
    static QString dataToString(const QVariantMap &data);
};

#endif // MESSAGE_H