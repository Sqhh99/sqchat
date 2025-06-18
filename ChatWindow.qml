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
    
    // 主布局
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // 左侧边栏 - 联系人列表
        ContactSidebar {
            id: contactSidebar
            Layout.fillHeight: true
            Layout.preferredWidth: 320
            Layout.minimumWidth: 250
            Layout.maximumWidth: 400
            
            currentChatId: chatWindow.currentChatId
            searchText: chatWindow.searchText
              onChatSelected: function(chatId, chatName) {
                console.log("ChatWindow.onChatSelected called with chatId:", chatId, "chatName:", chatName)
                console.log("Before setting - chatWindow.currentChatId:", chatWindow.currentChatId)
                chatWindow.currentChatId = chatId
                chatWindow.currentChatName = chatName
                console.log("After setting - chatWindow.currentChatId:", chatWindow.currentChatId)
                console.log("切换到聊天:", chatName)
            }
              onSearchUpdated: function(text) {
                chatWindow.searchText = text
            }
            
            onSettingsClicked: {
                chatWindow.settingsVisible = true
                settingsDialog.open()
            }
        }
        
        // 分隔线
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: "#e9ecef"
        }
        
        // 右侧主聊天区域
        ChatArea {
            id: chatArea
            Layout.fillHeight: true
            Layout.fillWidth: true
            
            currentChatId: chatWindow.currentChatId
            currentChatName: chatWindow.currentChatName
            isTyping: chatWindow.isTyping
            
            onTypingChanged: function(typing) {
                chatWindow.isTyping = typing
            }
        }
    }
    
    // 设置对话框
    SettingsDialog {
        id: settingsDialog
        
        onAccepted: {
            console.log("设置已保存")
            chatWindow.settingsVisible = false
        }
        
        onRejected: {
            console.log("设置已取消")
            chatWindow.settingsVisible = false
        }
    }
    
    // 通知功能
    NotificationManager {
        id: notificationManager
        parent: chatWindow.contentItem
    }
}
