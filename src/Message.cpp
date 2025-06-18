#include "include/Message.h"
#include <QStringList>
#include <QDebug>

Message::Message(QObject *parent)
    : QObject(parent)
    , m_type(MessageType::ERROR)
    , m_timestamp(QDateTime::currentDateTime())
{
}

Message::Message(MessageType type, const QVariantMap &data, QObject *parent)
    : QObject(parent)
    , m_type(type)
    , m_data(data)
    , m_timestamp(QDateTime::currentDateTime())
{
}

void Message::setType(MessageType type)
{
    if (m_type != type) {
        m_type = type;
        emit typeChanged();
    }
}

void Message::setData(const QVariantMap &data)
{
    if (m_data != data) {
        m_data = data;
        emit dataChanged();
    }
}

void Message::setTimestamp(const QDateTime &timestamp)
{
    if (m_timestamp != timestamp) {
        m_timestamp = timestamp;
        emit timestampChanged();
    }
}

void Message::setData(const QString &key, const QVariant &value)
{
    m_data[key] = value;
    emit dataChanged();
}

QVariant Message::getData(const QString &key, const QVariant &defaultValue) const
{
    return m_data.value(key, defaultValue);
}

QString Message::toString() const
{
    QString dataStr = dataToString(m_data);
    return QString("%1:%2").arg(static_cast<int>(m_type)).arg(dataStr);
}

Message* Message::fromString(const QString &messageString, QObject *parent)
{
    // 解析格式: messageType:key1=value1;key2=value2;...
    QStringList parts = messageString.split(':', Qt::KeepEmptyParts);
    if (parts.size() < 2) {
        qWarning() << "Invalid message format:" << messageString;
        return nullptr;
    }
    
    bool ok;
    int typeInt = parts[0].toInt(&ok);
    if (!ok) {
        qWarning() << "Invalid message type:" << parts[0];
        return nullptr;
    }
    
    MessageType type = static_cast<MessageType>(typeInt);
    QString dataString = parts.mid(1).join(':'); // 重新组合数据部分，防止数据中包含冒号
    QVariantMap data = parseDataString(dataString);
    
    return new Message(type, data, parent);
}

QVariantMap Message::parseDataString(const QString &dataString)
{
    QVariantMap data;
    if (dataString.isEmpty()) {
        return data;
    }
    
    QStringList items = dataString.split(';', Qt::SkipEmptyParts);
    for (const QString &item : items) {
        QStringList keyValue = item.split('=', Qt::KeepEmptyParts);
        if (keyValue.size() >= 2) {
            QString key = keyValue[0].trimmed();
            QString value = keyValue.mid(1).join('='); // 重新组合值部分，防止值中包含等号
            data[key] = value;
        }
    }
    
    return data;
}

QString Message::dataToString(const QVariantMap &data)
{
    QStringList items;
    for (auto it = data.constBegin(); it != data.constEnd(); ++it) {
        QString value = it.value().toString();
        items.append(QString("%1=%2").arg(it.key(), value));
    }
    return items.join(';');
}