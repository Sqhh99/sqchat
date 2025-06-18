import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: chatArea
    color: "#ffffff"
      property string currentChatId: ""
    property string currentChatName: ""
    property bool isTyping: false
    property var chatController: globalChatController
    
    signal typingChanged(bool typing)
    
    // 消息数据模型
    ListModel {
        id: messagesModel
    }
    
    // 监听聊天消息
    Connections {
        target: chatController
          function onPrivateMessageReceived(fromUserId, fromUsername, content, messageId, timestamp) {
            // 只显示当前聊天的消息
            if (fromUserId === chatArea.currentChatId) {
                messagesModel.append({
                    messageId: messageId,
                    text: content,
                    isOwn: false,
                    timestamp: formatTimestamp(timestamp),
                    status: "delivered",
                    fromUserId: fromUserId,
                    fromUsername: fromUsername
                })
                
                // 自动标记为已读
                chatController.markMessageRead(messageId, "private", fromUserId)
            }
        }
        
        function onChatHistoryReceived(type, targetId, messages) {
            if (type === "private" && targetId === chatArea.currentChatId) {
                messagesModel.clear()
                
                // 按时间排序并添加到模型
                var sortedMessages = messages.sort(function(a, b) {
                    return parseInt(a.timestamp) - parseInt(b.timestamp)
                })
                
                for (var i = 0; i < sortedMessages.length; i++) {
                    var msg = sortedMessages[i]
                    messagesModel.append({
                        messageId: msg.id,
                        text: msg.content,
                        isOwn: msg.from === "self", // 需要根据实际用户ID判断
                        timestamp: formatTimestamp(msg.timestamp),
                        status: "read",
                        fromUserId: msg.from,
                        fromUsername: msg.from                    })
                }
                
                // onCountChanged会自动处理滚动
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 聊天头部
        ChatHeader {
            id: chatHeader
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            
            chatName: chatArea.currentChatName
            isTyping: chatArea.isTyping
        }
        
        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#e9ecef"
        }
        
        // 消息列表区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f8f9fa"
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 16
                  ListView {
                    id: messageListView
                    width: parent.width
                    model: messagesModel
                    spacing: 8
                    verticalLayoutDirection: ListView.TopToBottom
                    
                    delegate: MessageBubble {
                        width: messageListView.width
                        messageText: model.text
                        isOwnMessage: model.isOwn
                        timestamp: model.timestamp
                        messageStatus: model.status
                    }
                    
                    // 自动滚动到底部 - 使用Timer避免递归
                    onCountChanged: {
                        if (count > 0) {
                            scrollToBottomTimer.start()
                        }
                    }
                    
                    Timer {
                        id: scrollToBottomTimer
                        interval: 10
                        repeat: false
                        onTriggered: {
                            messageListView.positionViewAtEnd()
                        }
                    }
                }
            }
        }
        
        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#e9ecef"
        }
        
        // 消息输入区域
        MessageInput {
            id: messageInput
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            onMessageSent: function(text) {
                console.log("ChatArea.onMessageSent called with text:", text)
                console.log("About to call chatArea.sendMessage function")
                try {
                    chatArea.sendMessage(text)
                    console.log("chatArea.sendMessage called successfully")
                } catch (error) {
                    console.log("Error calling chatArea.sendMessage:", error)
                }
            }
              onTypingChanged: function(typing) {
                chatArea.isTyping = typing
                chatArea.typingChanged(typing)
            }
        }
    }
    
    // 监听当前聊天切换
    property bool isLoadingHistory: false
    
    onCurrentChatIdChanged: {
        console.log("ChatArea.onCurrentChatIdChanged triggered, currentChatId:", currentChatId)
        if (currentChatId && chatController.isConnected && !isLoadingHistory) {
            console.log("Loading chat history for:", currentChatId)
            isLoadingHistory = true
            // 清空当前消息列表
            messagesModel.clear()
            // 暂时禁用聊天历史加载避免循环
            // chatController.getChatHistory("private", currentChatId, 50)
            // 延迟重置标志
            loadingTimer.start()
        } else {
            console.log("Skipping chat history load. Connected:", chatController.isConnected, "Loading:", isLoadingHistory)
        }
    }
    
    Timer {
        id: loadingTimer
        interval: 1000
        onTriggered: {
            chatArea.isLoadingHistory = false
        }
    }
    
    // 时间戳格式化函数
    function formatTimestamp(timestamp) {
        var date = new Date(parseInt(timestamp))
        var hours = date.getHours()
        var minutes = date.getMinutes()
        var ampm = hours >= 12 ? 'PM' : 'AM'
        hours = hours % 12
        hours = hours ? hours : 12
        minutes = minutes < 10 ? '0' + minutes : minutes
        return hours + ':' + minutes + ' ' + ampm
    }
    
    // 发送消息函数
    function sendMessage(text) {
        console.log("ChatArea.sendMessage called with:", text)
        console.log("currentChatId:", currentChatId)
        console.log("chatController.isConnected:", chatController.isConnected)
          if (text.trim() === "" || !currentChatId || !chatController.isConnected) {
            console.log("Send message cancelled - invalid conditions")
            return
        }
        
        var currentTime = new Date()
        var timeString = formatTimestamp(currentTime.getTime())
        
        // 先添加到本地消息列表
        messagesModel.append({
            messageId: "local_" + Date.now(),
            text: text,
            isOwn: true,
            timestamp: timeString,
            status: "sending"
        })
        
        // 发送到服务器
        console.log("Sending private message to:", currentChatId, "content:", text)
        chatController.sendPrivateMessage(currentChatId, text)
        
        // 模拟发送状态更新
        sendStatusTimer.start()
    }
    
    Timer {
        id: sendStatusTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (messagesModel.count > 0) {
                messagesModel.setProperty(messagesModel.count - 1, "status", "sent")
                // 再延迟更新为已送达
                deliveredTimer.start()
            }
        }
    }
    
    Timer {
        id: deliveredTimer
        interval: 2000
        repeat: false
        onTriggered: {
            if (messagesModel.count > 0) {
                messagesModel.setProperty(messagesModel.count - 1, "status", "delivered")
            }
        }
    }
}
