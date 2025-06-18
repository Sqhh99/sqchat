import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: addFriendDialog
    title: "添加好友"
    width: 400
    height: 300
    modal: true
    anchors.centerIn: parent
    
    property var chatController: globalChatController
    
    background: Rectangle {
        color: "#ffffff"
        radius: 8
        border.color: "#e9ecef"
        border.width: 1
    }
    
    contentItem: ColumnLayout {
        spacing: 20
        
        Text {
            text: "请输入好友的用户名或ID"
            font.pixelSize: 16
            color: "#212529"
            Layout.alignment: Qt.AlignHCenter
        }
        
        // 输入框
        Rectangle {
            Layout.fillWidth: true
            height: 45
            color: "white"
            border.color: friendIdInput.activeFocus ? "#007bff" : "#e9ecef"
            border.width: 2
            radius: 8
            
            TextInput {
                id: friendIdInput
                anchors.fill: parent
                anchors.margins: 16
                font.pixelSize: 14
                color: "#212529"
                selectByMouse: true
                
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "输入用户名或ID..."
                    color: "#adb5bd"
                    font.pixelSize: 14
                    visible: friendIdInput.text === ""
                }
            }
        }
        
        // 用户列表
        Text {
            text: "或从在线用户中选择："
            font.pixelSize: 14
            color: "#666"
        }
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ListView {
                id: usersListView
                width: parent.width
                model: chatController.usersList
                
                delegate: Rectangle {
                    width: usersListView.width
                    height: 40
                    color: userMouseArea.containsMouse ? "#f8f9fa" : "transparent"
                    radius: 4
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        
                        Text {
                            text: "👤"
                            font.pixelSize: 16
                        }
                          Text {
                            text: modelData.username + " (ID: " + modelData.userId + ")"
                            font.pixelSize: 14
                            color: "#212529"
                            Layout.fillWidth: true
                        }
                        
                        Button {
                            text: "添加"
                            
                            background: Rectangle {
                                color: parent.pressed ? "#0056b3" : (parent.hovered ? "#0069d9" : "#007bff")
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                friendIdInput.text = modelData.username
                            }
                        }
                    }
                    
                    MouseArea {
                        id: userMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            friendIdInput.text = modelData.username
                        }
                    }
                }
            }
        }
    }
    
    footer: DialogButtonBox {
        Button {
            text: "添加好友"
            enabled: friendIdInput.text.trim() !== ""
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            
            background: Rectangle {
                color: {
                    if (!parent.enabled) return "#e9ecef"
                    if (parent.pressed) return "#0056b3"
                    if (parent.hovered) return "#0069d9"
                    return "#007bff"
                }
                radius: 4
            }
            
            contentItem: Text {
                text: parent.text
                color: parent.enabled ? "white" : "#6c757d"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        
        Button {
            text: "取消"
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            
            background: Rectangle {
                color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "transparent")
                border.color: "#e9ecef"
                border.width: 1
                radius: 4
            }
            
            contentItem: Text {
                text: parent.text
                color: "#212529"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    
    onOpened: {
        // 打开对话框时获取用户列表
        chatController.getUsersList()
        friendIdInput.focus = true
    }
    
    onAccepted: {
        var friendId = friendIdInput.text.trim()
        if (friendId !== "") {
            chatController.addFriend(friendId)
            friendIdInput.text = ""
        }
    }
    
    // 监听添加好友结果
    Connections {
        target: chatController
        
        function onFriendAdded(friendId, username) {
            console.log("好友添加成功:", username)
            addFriendDialog.close()
        }
        
        function onErrorOccurred(error) {
            console.log("添加好友失败:", error)
            // 这里可以显示错误提示
        }
    }
}
