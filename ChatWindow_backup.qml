import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: chatWindow
    width: 1200
    height: 800
    title: "SQChat - 聊天"
    visible: true
    
    // 全局状态管理
    property string currentChatId: "emily"
    property string currentChatName: "Emily Johnson"
    property bool isTyping: false
    property string searchText: ""
    property bool settingsVisible: false
    
    // 消息数据模型
    ListModel {
        id: messagesModel
        
        ListElement {
            messageId: "msg1"
            text: "Hi Emily Yes, the shipment has been processed, and we expect it to arrive at your warehouse by Friday. I'll send you the tracking details shortly."
            isOwn: true
            timestamp: "11:01 AM"
            status: "read"
        }
        
        ListElement {
            messageId: "msg2"
            text: "That's great news! Also, I wanted to discuss the next batch. Can we assume Jordan Mac and Jordan 1s for the next order? The demand has been really strong this quarter!"
            isOwn: false
            timestamp: "11:21 AM"
            status: "delivered"
        }
        
        ListElement {
            messageId: "msg3"
            text: "Thanks for sharing the sales data! We can allocate more slots for you. Would you like to keep the same pricing and order volume, or do you need any adjustments?"
            isOwn: true
            timestamp: "11:22 AM"
            status: "read"
        }
        
        ListElement {
            messageId: "msg4"
            text: "Let's increase the Jordan 1 order by 20% since they're selling so fast. Also, do you have any updates on the custom branding options we discussed last time?"
            isOwn: false
            timestamp: "11:25 AM"
            status: "delivered"
        }
        
        ListElement {
            messageId: "msg5"
            text: "Will do! We're thrilled to keep growing together. Let's make this a big success!"
            isOwn: true
            timestamp: "11:26 AM"
            status: "sent"
        }
    }
    
    // 发送消息函数
    function sendMessage(text) {
        if (text.trim() === "") return
        
        var currentTime = new Date()
        var timeString = currentTime.getHours().toString().padStart(2, '0') + ":" + 
                        currentTime.getMinutes().toString().padStart(2, '0') + " " +
                        (currentTime.getHours() >= 12 ? "PM" : "AM")
        
        messagesModel.append({
            messageId: "msg" + (messagesModel.count + 1),
            text: text,
            isOwn: true,
            timestamp: timeString,
            status: "sending"
        })
        
        // 滚动到底部
        messageListView.positionViewAtEnd()
        
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
    
    // 切换聊天函数
    function switchChat(chatId, chatName) {
        currentChatId = chatId
        currentChatName = chatName
        // 这里可以加载不同用户的消息历史
        console.log("切换到聊天:", chatName)
    }    // 消息气泡组件
    Component {
        id: messageBubbleComponent
        
        Item {
            property string messageText: ""
            property bool isOwnMessage: false
            property string timestamp: ""
            property string messageStatus: "sent"
            
            width: parent ? parent.width : 400
            height: bubbleRect.height + 16
            
            // 动画效果
            opacity: 0
            scale: 0.8
            
            ParallelAnimation {
                id: appearAnimation
                running: true
                
                NumberAnimation {
                    target: parent
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 300
                    easing.type: Easing.OutQuad
                }
                
                NumberAnimation {
                    target: parent
                    property: "scale"
                    from: 0.8
                    to: 1.0
                    duration: 300
                    easing.type: Easing.OutBack
                }
            }
              Rectangle {
                id: bubbleRect
                
                property real maxWidth: parent ? parent.width * 0.7 : 400
                property real minWidth: 120
                property real contentBasedWidth: messageLabel.implicitWidth + 32
                
                width: Math.min(Math.max(contentBasedWidth, minWidth), maxWidth)
                height: messageLabel.implicitHeight + timestampRow.height + 20
                
                anchors.right: parent.isOwnMessage ? parent.right : undefined
                anchors.left: parent.isOwnMessage ? undefined : parent.left
                anchors.rightMargin: parent.isOwnMessage ? 8 : 0
                anchors.leftMargin: parent.isOwnMessage ? 0 : 8
                color: parent.isOwnMessage ? "#007bff" : "#f1f3f4"
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
                        bubbleRect.color = parent.isOwnMessage ? "#007bff" : "#f1f3f4"
                    }
                    onClicked: {
                        // 可以添加消息详情或操作菜单
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
                        text: bubbleRect.parent.messageText
                        color: bubbleRect.parent.isOwnMessage ? "white" : "#202124"
                        font.pixelSize: 14
                        wrapMode: Text.WordWrap
                        width: parent.width
                        lineHeight: 1.2
                    }
                    
                    Row {
                        id: timestampRow
                        anchors.right: parent.right
                        spacing: 4
                        
                        Text {
                            id: timestampLabel
                            text: bubbleRect.parent.timestamp
                            color: bubbleRect.parent.isOwnMessage ? "#e3f2fd" : "#5f6368"
                            font.pixelSize: 11
                        }
                        
                        // 消息状态图标（仅自己的消息显示）
                        Text {
                            id: statusIcon
                            visible: bubbleRect.parent.isOwnMessage
                            text: {
                                switch(bubbleRect.parent.messageStatus) {
                                    case "sending": return "🕐"
                                    case "sent": return "✓"
                                    case "delivered": return "✓✓"
                                    case "read": return "✓✓"
                                    default: return ""
                                }
                            }
                            color: bubbleRect.parent.messageStatus === "read" ? "#4CAF50" : 
                                   bubbleRect.parent.isOwnMessage ? "#e3f2fd" : "#5f6368"
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }
    }
    
    // 表情选择器
    Popup {
        id: emojiPicker
        width: 300
        height: 200
        modal: false
        
        background: Rectangle {
            color: "#ffffff"
            border.color: "#e9ecef"
            border.width: 1
            radius: 8
        }
        
        GridView {
            anchors.fill: parent
            anchors.margins: 10
            model: ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "😎", "🤓", "🧐", "😕", "😟", "🙁", "☹️", "😮", "😯", "😲", "😳", "🥺", "😦", "😧", "😨", "😰", "😥", "😢", "😭", "😱", "😖", "😣", "😞", "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬", "😈", "👿", "💀", "☠️", "💩", "🤡", "👹", "👺", "👻", "👽", "👾", "🤖", "🎃", "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿", "😾"]
            cellWidth: 30
            cellHeight: 30
            
            delegate: Rectangle {
                width: 28
                height: 28
                color: emojiMouse.containsMouse ? "#f0f0f0" : "transparent"
                radius: 4
                
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 20
                }
                
                MouseArea {
                    id: emojiMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        messageInput.insert(messageInput.cursorPosition, modelData)
                        emojiPicker.close()
                        messageInput.forceActiveFocus()
                    }
                }
            }
        }
    }
    
    // 消息搜索功能
    Popup {
        id: messageSearchPopup
        width: 400
        height: 300
        modal: true
        anchors.centerIn: parent
        
        property alias searchQuery: searchInput.text
        
        background: Rectangle {
            color: "#ffffff"
            border.color: "#e9ecef"
            border.width: 1
            radius: 8
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            Text {
                text: "搜索消息"
                font.pixelSize: 18
                font.bold: true
                color: "#212529"
            }
            
            TextField {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "输入搜索关键字..."
                
                onTextChanged: {
                    // 实时搜索
                    searchTimer.restart()
                }
                
                Timer {
                    id: searchTimer
                    interval: 300
                    onTriggered: {
                        performSearch(searchInput.text)
                    }
                }
            }
            
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                ListView {
                    id: searchResults
                    model: ListModel {
                        id: searchResultsModel
                    }
                    
                    delegate: Rectangle {
                        width: searchResults.width
                        height: 60
                        color: searchMouse.containsMouse ? "#f8f9fa" : "transparent"
                        
                        MouseArea {
                            id: searchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            
                            onClicked: {
                                // 跳转到消息
                                messageSearchPopup.close()
                                console.log("跳转到消息:", model.text)
                            }
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            
                            Text {
                                text: model.text || ""
                                font.pixelSize: 12
                                color: "#212529"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: model.timestamp || ""
                                font.pixelSize: 10
                                color: "#6c757d"
                            }
                        }
                    }
                }
            }
            
            Button {
                text: "关闭"
                Layout.alignment: Qt.AlignHCenter
                onClicked: messageSearchPopup.close()
            }
        }
    }
    
    // 消息搜索函数
    function performSearch(query) {
        searchResultsModel.clear()
        
        if (query.trim() === "") return
        
        for (var i = 0; i < messagesModel.count; i++) {
            var message = messagesModel.get(i)
            if (message.text.toLowerCase().includes(query.toLowerCase())) {
                searchResultsModel.append({
                    text: message.text,
                    timestamp: message.timestamp,
                    messageId: message.messageId
                })
            }
        }
    }
    
    // 主布局
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // 左侧边栏
        Rectangle {
            Layout.preferredWidth: 320
            Layout.fillHeight: true
            color: "#f8f9fa"
            border.color: "#e9ecef"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                // 标题
                Text {
                    text: "Chat Boxes"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#212529"
                }
                  // 搜索框
                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Search or start new chat"
                    leftPadding: 40
                    text: searchText
                    
                    onTextChanged: {
                        searchText = text
                        // 这里可以添加搜索逻辑
                        console.log("搜索:", text)
                    }
                    
                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16
                        color: "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🔍"
                            font.pixelSize: 12
                        }
                    }
                    
                    // 清除按钮
                    Button {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        visible: searchField.text.length > 0
                        text: "✕"
                        flat: true
                        
                        background: Rectangle {
                            color: "transparent"
                            radius: 10
                        }
                        
                        onClicked: {
                            searchField.clear()
                        }
                    }
                }
                  // 过滤按钮
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    property string activeFilter: "All"
                    
                    Button {
                        text: "All"
                        flat: true
                        property bool isActive: parent.activeFilter === "All"
                        background: Rectangle {
                            color: parent.isActive ? "#007bff" : (parent.pressed ? "#e9ecef" : "transparent")
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.isActive ? "white" : "#495057"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            parent.activeFilter = "All"
                            console.log("过滤器: All")
                        }
                    }
                    
                    Button {
                        text: "Archive"
                        flat: true
                        property bool isActive: parent.activeFilter === "Archive"
                        background: Rectangle {
                            color: parent.isActive ? "#007bff" : (parent.pressed ? "#e9ecef" : "transparent")
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.isActive ? "white" : "#495057"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            parent.activeFilter = "Archive"
                            console.log("过滤器: Archive")
                        }
                    }
                    
                    Button {
                        text: "Unread"
                        flat: true
                        property bool isActive: parent.activeFilter === "Unread"
                        background: Rectangle {
                            color: parent.isActive ? "#007bff" : (parent.pressed ? "#e9ecef" : "transparent")
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.isActive ? "white" : "#495057"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            parent.activeFilter = "Unread"
                            console.log("过滤器: Unread")
                        }
                    }
                }
                
                // 聊天列表
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: chatList
                        model: chatListModel
                        delegate: chatItemDelegate
                        spacing: 2
                    }
                }
                  // 底部图标
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        width: 32
                        height: 32
                        text: "📊"
                        flat: true
                        background: Rectangle {
                            color: parent.pressed ? "#e9ecef" : "transparent"
                            radius: 16
                        }
                        onClicked: {
                            console.log("打开统计")
                            showNotification("统计", "查看聊天统计数据")
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "统计"
                    }
                    
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        width: 32
                        height: 32
                        text: "📈"
                        flat: true
                        background: Rectangle {
                            color: parent.pressed ? "#e9ecef" : "transparent"
                            radius: 16
                        }
                        onClicked: {
                            console.log("打开趋势")
                            showNotification("趋势", "查看消息趋势")
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "趋势"
                    }
                    
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        width: 32
                        height: 32
                        text: "🏷️"
                        flat: true
                        background: Rectangle {
                            color: parent.pressed ? "#e9ecef" : "transparent"
                            radius: 16
                        }
                        onClicked: {
                            console.log("打开标签")
                            showNotification("标签", "管理聊天标签")
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "标签"
                    }
                    
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        width: 32
                        height: 32
                        text: "👤"
                        flat: true
                        background: Rectangle {
                            color: parent.pressed ? "#e9ecef" : "transparent"
                            radius: 16
                        }
                        onClicked: {
                            console.log("打开联系人")
                            showNotification("联系人", "管理联系人列表")
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "联系人"
                    }
                    
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        width: 32
                        height: 32
                        text: "📁"
                        flat: true
                        background: Rectangle {
                            color: parent.pressed ? "#e9ecef" : "transparent"
                            radius: 16
                        }
                        onClicked: {
                            console.log("打开文件管理")
                            showNotification("文件", "管理共享文件")
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "文件管理"
                    }
                    
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        width: 32
                        height: 32
                        text: "📧"
                        flat: true
                        background: Rectangle {
                            color: parent.pressed ? "#e9ecef" : "transparent"
                            radius: 16
                        }
                        onClicked: {
                            console.log("打开邮件")
                            showNotification("邮件", "查看邮件集成")
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "邮件"
                    }
                    
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        width: 32
                        height: 32
                        text: "📋"
                        flat: true
                        background: Rectangle {
                            color: parent.pressed ? "#e9ecef" : "transparent"
                            radius: 16
                        }
                        onClicked: {
                            console.log("打开剪贴板")
                            showNotification("剪贴板", "查看剪贴板历史")
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "剪贴板"
                    }
                    
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        width: 32
                        height: 32
                        text: "⚙️"
                        flat: true
                        background: Rectangle {
                            color: parent.pressed ? "#e9ecef" : "transparent"
                            radius: 16
                        }
                        onClicked: {
                            console.log("打开设置")
                            settingsDialog.open()
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "设置"
                    }
                }
            }
        }
        
        // 主聊天区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#ffffff"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0                // 聊天消息区域
                ScrollView {
                    id: messageScrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: messageListView.contentHeight
                    
                    // 自动滚动到底部
                    property bool autoScroll: true
                    
                    ListView {
                        id: messageListView
                        model: messagesModel
                        spacing: 12
                        topMargin: 20
                        bottomMargin: 20
                        leftMargin: 20
                        rightMargin: 20
                        
                        // 添加头部（日期）
                        header: Item {
                            width: messageListView.width - 40
                            height: 30
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: dateText.width + 16
                                height: 20
                                color: "#f0f0f0"
                                radius: 10
                                
                                Text {
                                    id: dateText
                                    anchors.centerIn: parent
                                    text: "Today, " + new Date().toLocaleDateString('en-US', {
                                        weekday: 'long',
                                        year: 'numeric',
                                        month: 'long',
                                        day: 'numeric'
                                    })
                                    font.pixelSize: 11
                                    color: "#6c757d"
                                }
                            }
                        }
                        
                        delegate: Loader {
                            width: messageListView.width - 40
                            sourceComponent: messageBubbleComponent
                            onLoaded: {
                                item.messageText = model.text
                                item.isOwnMessage = model.isOwn
                                item.timestamp = model.timestamp
                                item.messageStatus = model.status
                            }
                        }
                        
                        // 当内容变化时自动滚动到底部
                        onCountChanged: {
                            if (messageScrollView.autoScroll) {
                                Qt.callLater(positionViewAtEnd)
                            }
                        }
                    }
                      // 检测用户是否在底部
                    Component.onCompleted: {
                        // 连接到内部flickable的contentY变化信号
                        if (messageScrollView.ScrollBar && messageScrollView.ScrollBar.vertical) {
                            messageScrollView.ScrollBar.vertical.positionChanged.connect(function() {
                                var flickable = messageScrollView.contentItem
                                if (flickable) {
                                    var atBottom = (flickable.contentY >= (flickable.contentHeight - flickable.height - 50))
                                    autoScroll = atBottom
                                }
                            })
                        }
                    }
                    
                    // 监听contentItem的变化
                    onContentItemChanged: {
                        if (contentItem) {
                            contentItem.onContentYChanged.connect(function() {
                                var atBottom = (contentItem.contentY >= (contentItem.contentHeight - contentItem.height - 50))
                                autoScroll = atBottom
                            })
                        }
                    }
                    
                    // 添加"新消息"提示
                    Rectangle {
                        id: newMessageIndicator
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 20
                        width: 120
                        height: 30
                        color: "#007bff"
                        radius: 15
                        visible: !messageScrollView.autoScroll && isTyping
                        
                        Text {
                            anchors.centerIn: parent
                            text: "有新消息 ↓"
                            color: "white"
                            font.pixelSize: 12
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                messageListView.positionViewAtEnd()
                                messageScrollView.autoScroll = true
                            }
                        }
                    }
                }
                  // 输入区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(60, Math.min(120, messageInput.contentHeight + 24))
                    color: "#ffffff"
                    border.color: "#e9ecef"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8
                        
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            
                            TextArea {
                                id: messageInput
                                placeholderText: "Type your message..."
                                wrapMode: TextArea.Wrap
                                selectByMouse: true
                                
                                background: Rectangle {
                                    color: "#f8f9fa"
                                    radius: 20
                                    border.color: messageInput.activeFocus ? "#007bff" : "#e9ecef"
                                    border.width: 1
                                }
                                
                                leftPadding: 16
                                rightPadding: 16
                                topPadding: 12
                                bottomPadding: 12
                                
                                // 处理Enter键发送消息
                                Keys.onPressed: function(event) {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (event.modifiers & Qt.ControlModifier) {
                                            // Ctrl+Enter 换行
                                            messageInput.insert(messageInput.cursorPosition, "\n")
                                        } else {
                                            // Enter 发送消息
                                            event.accepted = true
                                            sendMessageButton.clicked()
                                        }
                                    }
                                }
                                
                                // 实时检测输入状态
                                onTextChanged: {
                                    isTyping = text.length > 0
                                    typingTimer.restart()
                                }
                                
                                Timer {
                                    id: typingTimer
                                    interval: 1000
                                    onTriggered: {
                                        if (messageInput.text.length === 0) {
                                            isTyping = false
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 文件上传按钮
                        Button {
                            width: 36
                            height: 36
                            text: "📎"
                            flat: true
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "transparent")
                                radius: 18
                            }
                            
                            onClicked: {
                                fileDialog.open()
                            }
                            
                            ToolTip.visible: hovered
                            ToolTip.text: "附加文件"
                            ToolTip.delay: 500
                        }
                        
                        // 表情按钮
                        Button {
                            width: 36
                            height: 36
                            text: "😊"
                            flat: true
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "transparent")
                                radius: 18
                            }
                              onClicked: {
                                // 打开表情选择器，定位在输入框上方
                                emojiPicker.x = parent.x
                                emojiPicker.y = parent.y - emojiPicker.height - 10
                                emojiPicker.open()
                            }
                            
                            ToolTip.visible: hovered
                            ToolTip.text: "表情"
                            ToolTip.delay: 500
                        }
                        
                        // 发送按钮
                        Button {
                            id: sendMessageButton
                            width: 36
                            height: 36
                            text: "➤"
                            flat: true
                            enabled: messageInput.text.trim().length > 0
                            
                            background: Rectangle {
                                color: parent.enabled ? (parent.pressed ? "#0056b3" : "#007bff") : "#e9ecef"
                                radius: 18
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "white" : "#6c757d"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 14
                            }
                            
                            onClicked: {
                                var message = messageInput.text.trim()
                                if (message.length > 0) {
                                    sendMessage(message)
                                    messageInput.clear()
                                    messageInput.forceActiveFocus()
                                }
                            }
                            
                            ToolTip.visible: hovered && enabled
                            ToolTip.text: "发送消息 (Enter)"
                            ToolTip.delay: 500
                        }
                    }                    // 正在输入指示器
                    Row {
                        id: typingIndicatorRow
                        anchors.left: parent.left
                        anchors.bottom: parent.top
                        anchors.leftMargin: 20
                        anchors.bottomMargin: 5
                        spacing: 4
                        visible: isTyping && currentChatName !== ""
                        
                        Text {
                            text: currentChatName + " 正在输入"
                            font.pixelSize: 10
                            color: "#6c757d"
                            font.italic: true
                        }
                        
                        Text {
                            id: typingDots
                            text: "."
                            font.pixelSize: 10
                            color: "#6c757d"
                        }
                        
                        SequentialAnimation {
                            running: typingIndicatorRow.visible && isTyping
                            loops: Animation.Infinite
                            
                            PropertyAnimation {
                                target: typingDots
                                property: "text"
                                from: "."
                                to: "..."
                                duration: 1000
                            }
                            
                            PropertyAnimation {
                                target: typingDots
                                property: "text"
                                from: "..."
                                to: "."
                                duration: 1000
                            }
                        }
                    }
                }
            }
        }
        
        // 右侧用户信息面板
        Rectangle {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: "#f8f9fa"
            border.color: "#e9ecef"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // 用户头像和信息
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 80
                        height: 80
                        radius: 40
                        color: "#ddd"
                        
                        Image {
                            anchors.fill: parent
                            source: "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ccircle cx='50' cy='50' r='50' fill='%23e9ecef'/%3E%3Ctext x='50' y='60' text-anchor='middle' font-size='40' fill='%23495057'%3E👤%3C/text%3E%3C/svg%3E"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Emily Johnson"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#212529"
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "emilyjohnson@sugarpanel.org"
                        font.pixelSize: 12
                        color: "#6c757d"
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Phone Number"
                        font.pixelSize: 10
                        color: "#6c757d"
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "+12 345 6789"
                        font.pixelSize: 14
                        color: "#212529"
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Username"
                        font.pixelSize: 10
                        color: "#6c757d"
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "@emilyjohnson123"
                        font.pixelSize: 14
                        color: "#212529"
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Hello, I'm Emily as Project Manager"
                        font.pixelSize: 12
                        color: "#495057"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                
                // 媒体文件部分
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Text {
                        text: "Media Files"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#212529"
                    }
                      RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        property string activeTab: "Media"
                        
                        Button {
                            text: "Files"
                            flat: true
                            property bool isActive: parent.activeTab === "Files"
                            background: Rectangle {
                                color: parent.isActive ? "#007bff" : (parent.pressed ? "#e9ecef" : "transparent")
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: parent.isActive ? "white" : "#495057"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                parent.activeTab = "Files"
                            }
                        }
                        
                        Button {
                            text: "Media"
                            flat: true
                            property bool isActive: parent.activeTab === "Media"
                            background: Rectangle {
                                color: parent.isActive ? "#007bff" : (parent.pressed ? "#e9ecef" : "transparent")
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: parent.isActive ? "white" : "#495057"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                parent.activeTab = "Media"
                            }
                        }
                        
                        Button {
                            text: "Links"
                            flat: true
                            property bool isActive: parent.activeTab === "Links"
                            background: Rectangle {
                                color: parent.isActive ? "#007bff" : (parent.pressed ? "#e9ecef" : "transparent")
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: parent.isActive ? "white" : "#495057"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                parent.activeTab = "Links"
                            }
                        }
                    }
                    
                    // 文件列表
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        ColumnLayout {
                            width: parent.width
                            spacing: 8
                            
                            Repeater {
                                model: [
                                    {name: "file-image-documentation.jpg", size: "4.2mb", date: "12 years, 1 January 2025"},
                                    {name: "file-image-documentation.jpg", size: "4.2mb", date: "12 years, 1 January 2025"},
                                    {name: "file-image-documentation.jpg", size: "1.3mb", date: "12 years, 1 January 2025"},
                                    {name: "file-image-documentation.jpg", size: "4.2mb", date: "12 years, 1 January 2025"},
                                    {name: "file-image-documentation.jpg", size: "4.1mb", date: "12 years, 1 January 2025"}
                                ]
                                  Rectangle {
                                    Layout.fillWidth: true
                                    height: 60
                                    color: "white"
                                    radius: 8
                                    border.color: fileItemMouse.containsMouse ? "#007bff" : "#e9ecef"
                                    border.width: 1
                                    
                                    // 悬停效果
                                    Behavior on border.color {
                                        ColorAnimation { duration: 200 }
                                    }
                                    
                                    MouseArea {
                                        id: fileItemMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        
                                        onClicked: {
                                            console.log("打开文件:", modelData.name)
                                            // 这里可以添加文件预览或下载逻辑
                                        }
                                        
                                        onDoubleClicked: {
                                            console.log("下载文件:", modelData.name)
                                        }
                                    }
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 8
                                        
                                        Rectangle {
                                            width: 32
                                            height: 32
                                            color: "#007bff"
                                            radius: 4
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: {
                                                    var ext = modelData.name.split('.').pop().toLowerCase()
                                                    switch(ext) {
                                                        case 'jpg':
                                                        case 'jpeg':
                                                        case 'png':
                                                        case 'gif':
                                                            return "🖼️"
                                                        case 'pdf':
                                                            return "📄"
                                                        case 'doc':
                                                        case 'docx':
                                                            return "📝"
                                                        case 'mp4':
                                                        case 'avi':
                                                            return "🎥"
                                                        case 'mp3':
                                                        case 'wav':
                                                            return "🎵"
                                                        default:
                                                            return "📁"
                                                    }
                                                }
                                                color: "white"
                                                font.pixelSize: 16
                                            }
                                        }
                                        
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            
                                            Text {
                                                text: modelData.name
                                                font.pixelSize: 12
                                                color: "#212529"
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                            
                                            Row {
                                                spacing: 8
                                                
                                                Text {
                                                    text: modelData.size
                                                    font.pixelSize: 10
                                                    color: "#6c757d"
                                                }
                                                
                                                Text {
                                                    text: "•"
                                                    font.pixelSize: 10
                                                    color: "#6c757d"
                                                }
                                                
                                                Text {
                                                    text: modelData.date
                                                    font.pixelSize: 10
                                                    color: "#6c757d"
                                                }
                                            }
                                        }
                                        
                                        Button {
                                            width: 24
                                            height: 24
                                            text: "⋯"
                                            flat: true
                                            visible: fileItemMouse.containsMouse
                                            
                                            background: Rectangle {
                                                color: parent.pressed ? "#e9ecef" : "transparent"
                                                radius: 12
                                            }
                                            
                                            onClicked: {
                                                fileContextMenu.file = modelData
                                                fileContextMenu.popup()
                                            }
                                        }
                                    }
                                    
                                    // 文件操作菜单
                                    Menu {
                                        id: fileContextMenu
                                        
                                        property var file: null
                                        
                                        MenuItem {
                                            text: "预览"
                                            onTriggered: {
                                                console.log("预览文件:", fileContextMenu.file.name)
                                            }
                                        }
                                        
                                        MenuItem {
                                            text: "下载"
                                            onTriggered: {
                                                console.log("下载文件:", fileContextMenu.file.name)
                                                showNotification("下载开始", "正在下载 " + fileContextMenu.file.name)
                                            }
                                        }
                                        
                                        MenuItem {
                                            text: "转发"
                                            onTriggered: {
                                                console.log("转发文件:", fileContextMenu.file.name)
                                            }
                                        }
                                        
                                        MenuSeparator {}
                                        
                                        MenuItem {
                                            text: "删除"
                                            onTriggered: {
                                                console.log("删除文件:", fileContextMenu.file.name)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 聊天列表数据模型
    ListModel {
        id: chatListModel
        
        ListElement {
            name: "James Carter"
            message: "Hey, I'm interested in the Air Jordans you have. I need to order..."
            time: "11:41 AM"
            avatar: "👤"
            unread: false
        }
        
        ListElement {
            name: "Sophia Lee"
            message: "Thank you for ordering a pair of our limited edition shoes..."
            time: "11:23 AM"
            avatar: "👤"
            unread: false
        }
        
        ListElement {
            name: "Emily Johnson"
            message: "Hey thank you guys offer the 'Air Jordan edition' collection..."
            time: "11:47 AM"
            avatar: "👤"
            unread: true
        }
        
        ListElement {
            name: "David Smith"
            message: "Can you give me more details about the latest collection?"
            time: "11:41 AM"
            avatar: "👤"
            unread: false
        }
        
        ListElement {
            name: "Olivia Martinez"
            message: "Hi, I recently placed an order, but I need to change the address."
            time: "11:47 AM"
            avatar: "👤"
            unread: false
        }
        
        ListElement {
            name: "Sarah Thompson"
            message: "I received a damaged pair and need assistance."
            time: "11:41 AM"
            avatar: "👤"
            unread: false
        }
        
        ListElement {
            name: "Michael Brown"
            message: "I'm interested in bulk ordering for our store. Please let me know..."
            time: "11:41 AM"
            avatar: "👤"
            unread: false
        }
        
        ListElement {
            name: "Daniel Wilson"
            message: "I have some specific requirements. I want to customize my..."
            time: "11:23 AM"
            avatar: "👤"
            unread: false
        }
        
        ListElement {
            name: "Chris Evans"
            message: "Hey, I saw your story on Instagram about the new shoes."
            time: "11:29 AM"
            avatar: "👤"
            unread: false
        }
        
        ListElement {
            name: "Jessica Adams"
            message: ""
            time: ""
            avatar: "👤"
            unread: false
        }
    }
    
    // 聊天项委托
    Component {
        id: chatItemDelegate
        
        Rectangle {
            width: chatList.width
            height: 72
            color: model.name === currentChatName ? "#e3f2fd" : (hoverArea.containsMouse ? "#f5f5f5" : "transparent")
            
            // 添加动画效果
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
            
            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                
                onClicked: {
                    // 切换到选中的聊天
                    switchChat(model.name.toLowerCase().replace(" ", ""), model.name)
                    
                    // 标记为已读
                    if (model.unread) {
                        chatListModel.setProperty(index, "unread", false)
                    }
                }
                
                // 右键菜单
                onPressAndHold: {
                    contextMenu.x = mouseX
                    contextMenu.y = mouseY
                    contextMenu.open()
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    // 头像
                    Rectangle {
                        width: 48
                        height: 48
                        radius: 24
                        color: "#ddd"
                        
                        // 在线状态指示器
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: "#4CAF50"
                            border.color: "white"
                            border.width: 2
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            visible: Math.random() > 0.5 // 模拟在线状态
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: model.avatar
                            font.pixelSize: 24
                        }
                        
                        // 悬停效果
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = Qt.lighter(parent.color, 1.1)
                            onExited: parent.color = "#ddd"
                        }
                    }
                    
                    // 消息内容
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: model.name
                                font.pixelSize: 14
                                font.bold: model.unread
                                color: "#212529"
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: model.time
                                font.pixelSize: 12
                                color: model.unread ? "#007bff" : "#6c757d"
                                font.bold: model.unread
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: model.message || "点击开始聊天..."
                                font.pixelSize: 12
                                color: model.unread ? "#495057" : "#6c757d"
                                font.bold: model.unread
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }
                            
                            // 未读消息数量
                            Rectangle {
                                width: unreadText.contentWidth + 8
                                height: 16
                                radius: 8
                                color: "#007bff"
                                visible: model.unread
                                
                                Text {
                                    id: unreadText
                                    anchors.centerIn: parent
                                    text: Math.floor(Math.random() * 5) + 1 // 模拟未读数量
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                        }
                    }
                    
                    // 更多操作按钮
                    Button {
                        width: 24
                        height: 24
                        text: "⋯"
                        flat: true
                        visible: hoverArea.containsMouse
                        
                        background: Rectangle {
                            color: parent.pressed ? "#e9ecef" : "transparent"
                            radius: 12
                        }
                        
                        onClicked: {
                            contextMenu.open()
                        }
                    }
                }
                
                // 右键菜单
                Menu {
                    id: contextMenu
                    
                    MenuItem {
                        text: "标记为已读"
                        enabled: model.unread
                        onTriggered: {
                            chatListModel.setProperty(index, "unread", false)
                        }
                    }
                    
                    MenuItem {
                        text: "置顶聊天"
                        onTriggered: {
                            console.log("置顶聊天:", model.name)
                        }
                    }
                    
                    MenuItem {
                        text: "存档聊天"
                        onTriggered: {
                            console.log("存档聊天:", model.name)
                        }
                    }
                    
                    MenuSeparator {}
                    
                    MenuItem {
                        text: "删除聊天"
                        onTriggered: {
                            deleteConfirmDialog.chatIndex = index
                            deleteConfirmDialog.chatName = model.name
                            deleteConfirmDialog.open()
                        }
                    }
                }
            }
        }
    }
    
    // 删除确认对话框
    Dialog {
        id: deleteConfirmDialog
        title: "确认删除"
        modal: true
        anchors.centerIn: parent
        
        property int chatIndex: -1
        property string chatName: ""
        
        ColumnLayout {
            Text {
                text: "确定要删除与 " + deleteConfirmDialog.chatName + " 的聊天记录吗？"
                wrapMode: Text.WordWrap
            }
            
            Text {
                text: "此操作无法撤销。"
                color: "#dc3545"
                font.pixelSize: 12
            }
        }
        
        standardButtons: Dialog.Yes | Dialog.No
        
        onAccepted: {
            if (chatIndex >= 0) {
                chatListModel.remove(chatIndex)
                console.log("删除聊天:", chatName)
            }
        }
    }
    
    // 文件选择对话框
    FileDialog {
        id: fileDialog
        title: "选择要发送的文件"
        nameFilters: ["图片文件 (*.jpg *.jpeg *.png *.gif)", "文档文件 (*.pdf *.doc *.docx *.txt)", "所有文件 (*)"]
        
        onAccepted: {
            console.log("选择文件:", selectedFile)
            // 这里可以添加文件上传逻辑
            var fileName = selectedFile.toString().split('/').pop()
            sendMessage("📎 " + fileName)
        }
    }
    
    // 设置对话框
    Dialog {
        id: settingsDialog
        title: "设置"
        modal: true
        width: 400
        height: 500
        anchors.centerIn: parent
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            
            GroupBox {
                title: "外观设置"
                Layout.fillWidth: true
                
                ColumnLayout {
                    anchors.fill: parent
                    
                    Row {
                        spacing: 10
                        
                        Text {
                            text: "主题:"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        ComboBox {
                            model: ["浅色", "深色", "自动"]
                            currentIndex: 0
                            onCurrentTextChanged: {
                                console.log("主题切换为:", currentText)
                            }
                        }
                    }
                    
                    CheckBox {
                        text: "启用动画效果"
                        checked: true
                        onCheckedChanged: {
                            console.log("动画效果:", checked)
                        }
                    }
                    
                    CheckBox {
                        text: "显示在线状态"
                        checked: true
                        onCheckedChanged: {
                            console.log("在线状态:", checked)
                        }
                    }
                }
            }
            
            GroupBox {
                title: "通知设置"
                Layout.fillWidth: true
                
                ColumnLayout {
                    anchors.fill: parent
                    
                    CheckBox {
                        text: "桌面通知"
                        checked: true
                        onCheckedChanged: {
                            console.log("桌面通知:", checked)
                        }
                    }
                    
                    CheckBox {
                        text: "声音提醒"
                        checked: true
                        onCheckedChanged: {
                            console.log("声音提醒:", checked)
                        }
                    }
                    
                    CheckBox {
                        text: "消息预览"
                        checked: false
                        onCheckedChanged: {
                            console.log("消息预览:", checked)
                        }
                    }
                }
            }
            
            GroupBox {
                title: "隐私设置"
                Layout.fillWidth: true
                
                ColumnLayout {
                    anchors.fill: parent
                    
                    CheckBox {
                        text: "已读回执"
                        checked: true
                        onCheckedChanged: {
                            console.log("已读回执:", checked)
                        }
                    }
                    
                    CheckBox {
                        text: "最后在线时间"
                        checked: true
                        onCheckedChanged: {
                            console.log("最后在线时间:", checked)
                        }
                    }
                    
                    CheckBox {
                        text: "正在输入状态"
                        checked: true
                        onCheckedChanged: {
                            console.log("正在输入状态:", checked)
                        }
                    }
                }
            }
        }
        
        standardButtons: Dialog.Ok | Dialog.Cancel
        
        onAccepted: {
            console.log("设置已保存")
            showNotification("设置", "设置已保存")
        }
    }
    
    // 全局快捷键处理
    Shortcut {
        sequence: "Ctrl+N"
        onActivated: {
            // 新建聊天
            console.log("新建聊天快捷键")
        }
    }
    
    Shortcut {
        sequence: "Ctrl+F"
        onActivated: {
            // 聚焦搜索框
            searchField.forceActiveFocus()
        }
    }
    
    Shortcut {
        sequence: "Escape"
        onActivated: {
            // 取消当前操作
            messageInput.forceActiveFocus()
        }
    }
    
    // 快捷键增强
    Shortcut {
        sequence: "Ctrl+K"
        onActivated: {
            // 快速切换聊天
            console.log("快速切换聊天")
        }
    }
    
    Shortcut {
        sequence: "Ctrl+Shift+F"
        onActivated: {
            // 全局搜索消息
            messageSearchPopup.open()
            searchInput.forceActiveFocus()
        }
    }
    
    Shortcut {
        sequence: "Ctrl+E"
        onActivated: {
            // 打开表情选择器
            emojiPicker.x = messageInput.x
            emojiPicker.y = messageInput.y - emojiPicker.height - 10
            emojiPicker.open()
        }
    }
    
    // 自动保存草稿功能
    Timer {
        id: draftSaveTimer
        interval: 2000
        repeat: false
        onTriggered: {
            if (messageInput.text.trim() !== "") {
                console.log("保存草稿:", messageInput.text)
                // 这里可以保存到本地存储
            }
        }
    }
    
    // 监听输入变化来保存草稿
    Connections {
        target: messageInput
        function onTextChanged() {
            draftSaveTimer.restart()
        }
    }
    
    // 消息状态同步
    Timer {
        id: statusSyncTimer
        interval: 5000
        repeat: true
        running: true
        onTriggered: {
            // 模拟从服务器同步消息状态
            for (var i = 0; i < messagesModel.count; i++) {
                var msg = messagesModel.get(i)
                if (msg.status === "delivered" && Math.random() > 0.7) {
                    messagesModel.setProperty(i, "status", "read")
                }
            }
        }
    }
    
    // 通知系统（可以扩展为系统通知）
    function showNotification(title, message) {
        notificationPopup.title = title
        notificationPopup.message = message
        notificationPopup.open()
    }
    
    // 通知弹窗
    Popup {
        id: notificationPopup
        x: parent.width - width - 20
        y: 20
        width: 300
        height: 80
        
        property string title: ""
        property string message: ""
        
        background: Rectangle {
            color: "#ffffff"
            border.color: "#e9ecef"
            border.width: 1
            radius: 8
            
            // 阴影效果
            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                color: "transparent"
                border.color: "#20000000"
                border.width: 1
                radius: 10
                z: -1
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            
            Text {
                text: notificationPopup.title
                font.bold: true
                font.pixelSize: 14
                color: "#212529"
            }
            
            Text {
                text: notificationPopup.message
                font.pixelSize: 12
                color: "#6c757d"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
        
        // 自动关闭
        Timer {
            running: notificationPopup.opened
            interval: 3000
            onTriggered: notificationPopup.close()
        }
        
        // 点击关闭
        MouseArea {
            anchors.fill: parent
            onClicked: notificationPopup.close()
        }
    }
}
