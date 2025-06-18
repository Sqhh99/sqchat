import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: messageBubble
    height: bubbleRect.height + 16
    
    property string messageText: ""
    property bool isOwnMessage: false
    property string timestamp: ""
    property string messageStatus: "sent"
    
    // 动画效果
    opacity: 0
    scale: 0.8
    
    ParallelAnimation {
        running: true
        
        NumberAnimation {
            target: messageBubble
            property: "opacity"
            from: 0
            to: 1
            duration: 300
            easing.type: Easing.OutQuad
        }
        
        NumberAnimation {
            target: messageBubble
            property: "scale"
            from: 0.8
            to: 1.0
            duration: 300
            easing.type: Easing.OutBack
        }
    }
    
    Rectangle {
        id: bubbleRect
        
        property real maxWidth: parent.width * 0.7
        property real minWidth: 120
        property real contentBasedWidth: messageLabel.implicitWidth + 32
        
        width: Math.min(Math.max(contentBasedWidth, minWidth), maxWidth)
        height: messageLabel.implicitHeight + timestampRow.height + 20
        
        anchors.right: messageBubble.isOwnMessage ? parent.right : undefined
        anchors.left: messageBubble.isOwnMessage ? undefined : parent.left
        anchors.rightMargin: messageBubble.isOwnMessage ? 8 : 0
        anchors.leftMargin: messageBubble.isOwnMessage ? 0 : 8
        color: messageBubble.isOwnMessage ? "#007bff" : "#f1f3f4"
        radius: 18
        
        // 简单的阴影效果
        border.color: "#10000000"
        border.width: 1
        
        // 悬停效果
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                bubbleRect.color = Qt.lighter(bubbleRect.color, 1.1)
            }
            onExited: {
                bubbleRect.color = messageBubble.isOwnMessage ? "#007bff" : "#f1f3f4"
            }
            onClicked: {
                console.log("消息被点击:", messageLabel.text)
            }
        }
        
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 4
            
            Text {
                id: messageLabel
                text: messageBubble.messageText
                font.pixelSize: 14
                color: messageBubble.isOwnMessage ? "white" : "#212529"
                wrapMode: Text.WordWrap
                width: parent.width
                lineHeight: 1.4
                textFormat: Text.PlainText
            }
            
            Row {
                id: timestampRow
                spacing: 4
                anchors.right: parent.right
                
                Text {
                    text: messageBubble.timestamp
                    font.pixelSize: 11
                    color: messageBubble.isOwnMessage ? "#ffffff80" : "#6c757d"
                }
                
                // 消息状态指示器（仅自己的消息显示）
                Text {
                    visible: messageBubble.isOwnMessage
                    text: {
                        switch (messageBubble.messageStatus) {
                            case "sending": return "⏱"
                            case "sent": return "✓"
                            case "delivered": return "✓✓"
                            case "read": return "✓✓"
                            default: return ""
                        }
                    }
                    font.pixelSize: 11
                    color: {
                        if (messageBubble.messageStatus === "read") return "#4CAF50"
                        else if (messageBubble.isOwnMessage) return "#ffffff80"
                        else return "#6c757d"
                    }
                }
            }
        }
    }
}
