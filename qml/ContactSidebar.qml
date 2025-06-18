import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sidebar
    color: "#f8f9fa"
    border.color: "#e9ecef"
    border.width: 1
    
    property string currentChatId: ""
    property string searchText: ""
    property var chatController: globalChatController
    
    signal chatSelected(string chatId, string chatName)
    signal searchUpdated(string text)
    signal settingsClicked()
    
    // 监听好友列表变化
    Connections {
        target: chatController
        
        function onFriendsListChanged() {
            console.log("好友列表更新，共", chatController.friendsList.length, "个好友")
        }
        
        function onFriendAdded(friendId, username) {
            console.log("新好友添加:", username)
            // 重新获取好友列表
            chatController.getFriendsList()
        }
    }
    
    Component.onCompleted: {
        // 组件加载完成后获取好友列表
        if (chatController.isConnected) {
            chatController.getFriendsList()
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // 顶部搜索栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "white"
                border.color: "#e9ecef"
                border.width: 1
                radius: 20
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 8
                    
                    Text {
                        text: "🔍"
                        font.pixelSize: 16
                        color: "#6c757d"
                    }
                    
                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.pixelSize: 14
                        color: "#212529"
                        selectByMouse: true
                        
                        onTextChanged: {
                            sidebar.searchText = text
                            sidebar.searchUpdated(text)
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: "搜索联系人..."
                                color: "#adb5bd"
                                font.pixelSize: 14
                                visible: searchInput.text === ""
                            }
                        }
                    }
                }            }
            
            // 添加好友按钮
            Button {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                
                background: Rectangle {
                    color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "transparent")
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 20
                }
                
                contentItem: Text {
                    text: "➕"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: addFriendDialog.open()
            }
            
            // 设置按钮
            Button {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                
                background: Rectangle {
                    color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "transparent")
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 20
                }
                
                contentItem: Text {
                    text: "⚙️"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: sidebar.settingsClicked()
            }
        }
          // 好友列表
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ListView {
                id: contactListView
                width: parent.width
                model: chatController.friendsList
                spacing: 4
                  delegate: ContactItem {
                    width: contactListView.width
                    contactData: {
                        // 转换好友数据格式以适配ContactItem
                        return {
                            "contactId": modelData.userId,
                            "name": modelData.username,
                            "lastMessage": "点击开始聊天...",
                            "timestamp": "",
                            "unreadCount": 0,
                            "isOnline": modelData.online,
                            "avatar": "👤"
                        }
                    }
                    isSelected: modelData.userId === sidebar.currentChatId
                      onClicked: {
                        console.log("ContactItem clicked - userId:", modelData.userId, "username:", modelData.username)
                        console.log("Full modelData:", JSON.stringify(modelData))
                        sidebar.chatSelected(modelData.userId, modelData.username)
                    }
                }
                
                // 空状态提示
                Rectangle {
                    visible: contactListView.count === 0
                    anchors.centerIn: parent
                    width: parent.width
                    height: 100
                    color: "transparent"
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "暂无好友"
                            font.pixelSize: 16
                            color: "#6c757d"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: "点击右上角 ➕ 添加好友"
                            font.pixelSize: 12
                            color: "#adb5bd"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
        
        // 底部状态栏
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "transparent"
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: "#22c55e"
                }
                
                Text {
                    text: "在线"
                    font.pixelSize: 12
                    color: "#6c757d"
                }
                
                Item { Layout.fillWidth: true }
                  Text {
                    text: chatController.friendsList.length + " 个好友"
                    font.pixelSize: 12
                    color: "#6c757d"
                }
            }
        }
    }
    
    // 添加好友对话框
    AddFriendDialog {
        id: addFriendDialog
    }
}
