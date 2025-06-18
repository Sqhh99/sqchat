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
                addMessage({
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
        
        function onLocalChatHistoryLoaded(type, targetId, messages) {
            if (type === "private" && targetId === chatArea.currentChatId) {
                messagesModel.clear()
                
                // 按时间排序并添加到模型
                var sortedMessages = messages.sort(function(a, b) {
                    return parseInt(a.timestamp) - parseInt(b.timestamp)
                })
                
                for (var i = 0; i < sortedMessages.length; i++) {
                    var msg = sortedMessages[i]
                    // 判断消息是否被撤回
                    var messageText = msg.recalled ? "[消息已撤回]" : msg.content
                    
                    messagesModel.append({
                        messageId: msg.messageId,
                        text: messageText,
                        isOwn: msg.fromUserId === globalAuthController.currentUserId, // 根据发送者判断
                        timestamp: formatTimestamp(msg.timestamp),
                        status: msg.isRead ? "read" : "delivered",
                        fromUserId: msg.fromUserId,
                        fromUsername: msg.fromUserId, // 这里可以后续优化为显示用户名
                        recalled: msg.recalled || false
                    })
                }
                  console.log("本地聊天记录加载完成，消息数量:", messages.length)
                // 加载完成后滚动到底部
                Qt.callLater(function() {
                    scrollToBottom()
                })
            }
        }
    }
      // 强制滚动到底部的函数
    function scrollToBottom() {
        if (messageListView && messagesModel.count > 0) {
            messageListView.userScrolling = false
            messageListView.positionViewAtEnd()
            // 确保滚动完成
            Qt.callLater(function() {
                messageListView.positionViewAtEnd()
                messageListView.atBottom = true
            })
        }
    }
    
    // 添加新消息的函数，带自动滚动
    function addMessage(messageData) {
        messagesModel.append(messageData)
        Qt.callLater(function() {
            scrollToBottom()
        })
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
              ListView {
                id: messageListView
                anchors.fill: parent
                anchors.margins: 16
                model: messagesModel
                spacing: 8
                clip: true
                verticalLayoutDirection: ListView.TopToBottom
                
                // 启用鼠标滚轮滚动
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds
                
                // 记录用户是否在手动滚动
                property bool userScrolling: false
                property bool atBottom: true
                
                delegate: MessageBubble {
                    width: messageListView.width
                    messageText: model.text
                    isOwnMessage: model.isOwn
                    timestamp: model.timestamp
                    messageStatus: model.status
                }
                
                // 监听用户滚动状态
                onMovingChanged: {
                    if (moving) {
                        userScrolling = true
                    }
                }
                
                onFlickingChanged: {
                    if (flicking) {
                        userScrolling = true
                    }
                }
                
                // 监听垂直位置变化，判断是否在底部
                onContentYChanged: {
                    var threshold = 50 // 距离底部50像素内认为是在底部
                    atBottom = (contentY >= contentHeight - height - threshold)
                    
                    // 如果用户滚动到非底部区域，停止自动滚动
                    if (!atBottom && userScrolling) {
                        scrollToBottomTimer.stop()
                    }
                }
                
                // 只有在用户没有手动滚动且在底部时才自动滚动
                onCountChanged: {
                    if (count > 0 && (!userScrolling || atBottom)) {
                        scrollToBottomTimer.start()
                    }
                    userScrolling = false // 重置滚动状态
                }
                  Timer {
                    id: scrollToBottomTimer
                    interval: 50 // 增加延迟确保布局完成
                    repeat: false
                    onTriggered: {
                        // 只有当用户不在手动滚动或者在底部时才自动滚动
                        if (!messageListView.userScrolling || messageListView.atBottom) {
                            messageListView.positionViewAtEnd()
                            // 双重保险，确保滚动到最底部
                            Qt.callLater(function() {
                                messageListView.positionViewAtEnd()
                                messageListView.atBottom = true
                            })
                        }
                    }
                }
                
                // 添加滚动条
                ScrollBar.vertical: ScrollBar {
                    id: verticalScrollBar
                    active: true
                    policy: ScrollBar.AsNeeded
                    
                    // 自定义滚动条样式
                    contentItem: Rectangle {
                        implicitWidth: 6
                        implicitHeight: 100
                        radius: 3
                        color: verticalScrollBar.pressed ? "#a0a0a0" : "#c0c0c0"
                        
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                    
                    background: Rectangle {
                        implicitWidth: 6
                        implicitHeight: 100
                        color: "transparent"
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
        if (currentChatId && !isLoadingHistory && globalChatHistoryManager.getCurrentUserId() !== "") {
            console.log("Loading local chat history for:", currentChatId)
            isLoadingHistory = true
            // 清空当前消息列表
            messagesModel.clear()
            // 加载本地聊天历史
            chatController.loadLocalChatHistory("private", currentChatId, 50)
            // 延迟重置标志
            loadingTimer.start()
        } else {
            console.log("Skipping chat history load. Loading:", isLoadingHistory, "CurrentUserId:", globalChatHistoryManager.getCurrentUserId())
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
        addMessage({
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
    
    // 组件完成时的初始化
    Component.onCompleted: {
        console.log("ChatArea组件初始化完成")
        // 确保初始时滚动条在底部
        Qt.callLater(function() {
            scrollToBottom()
        })
    }
    
    // 监听ChatHistoryManager初始化完成
    Connections {
        target: globalChatHistoryManager
        
        function onOfflineMessagesAvailable(count) {
            console.log("收到离线消息通知，数量:", count)
        }
    }
    
    // 监听用户登录状态，当用户登录成功后重新加载当前聊天记录
    Connections {
        target: globalAuthController
        
        function onUserLoggedIn(userId) {
            console.log("用户登录成功，重新加载聊天记录, userId:", userId)
            // 等待一小段时间确保ChatHistoryManager完全初始化
            reloadTimer.start()
        }
    }
    
    Timer {
        id: reloadTimer
        interval: 500
        onTriggered: {
            if (currentChatId && globalChatHistoryManager.getCurrentUserId() !== "") {
                console.log("重新加载当前聊天记录:", currentChatId)
                messagesModel.clear()
                chatController.loadLocalChatHistory("private", currentChatId, 50)
            }
        }
    }
}
