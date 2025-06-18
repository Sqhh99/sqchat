import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: settingsDialog
    title: "设置"
    width: 500
    height: 600
    modal: true
    anchors.centerIn: parent
    
    // 设置数据模型
    property var settings: ({
        // 外观设置
        theme: "浅色",
        enableAnimations: true,
        showOnlineStatus: true,
        
        // 通知设置
        desktopNotifications: true,
        soundAlerts: true,
        messagePreview: false,
        
        // 聊天设置
        showLastSeen: true,
        showTypingStatus: true
    })
    
    background: Rectangle {
        color: "#ffffff"
        radius: 8
        border.color: "#e9ecef"
        border.width: 1
        
        // 阴影效果
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            color: "transparent"
            border.color: "#20000000"
            border.width: 1
            radius: 12
            z: -1
        }
    }
    
    contentItem: ScrollView {
        anchors.fill: parent
        
        ColumnLayout {
            width: parent.width
            spacing: 24
            
            // 外观设置
            GroupBox {
                Layout.fillWidth: true
                title: "外观设置"
                
                background: Rectangle {
                    color: "transparent"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 4
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    
                    // 主题选择
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "主题:"
                            font.pixelSize: 14
                            color: "#212529"
                            Layout.preferredWidth: 80
                        }
                        
                        ComboBox {
                            id: themeCombo
                            Layout.fillWidth: true
                            model: ["浅色", "深色", "自动"]
                            currentIndex: model.indexOf(settingsDialog.settings.theme)
                            
                            onCurrentTextChanged: {
                                settingsDialog.settings.theme = currentText
                            }
                        }
                    }
                    
                    // 启用动画效果
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: animationsCheck
                            checked: settingsDialog.settings.enableAnimations
                            onCheckedChanged: {
                                settingsDialog.settings.enableAnimations = checked
                            }
                        }
                        
                        Text {
                            text: "启用动画效果"
                            font.pixelSize: 14
                            color: "#212529"
                        }
                    }
                    
                    // 显示在线状态
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: onlineStatusCheck
                            checked: settingsDialog.settings.showOnlineStatus
                            onCheckedChanged: {
                                settingsDialog.settings.showOnlineStatus = checked
                            }
                        }
                        
                        Text {
                            text: "显示在线状态"
                            font.pixelSize: 14
                            color: "#212529"
                        }
                    }
                }
            }
            
            // 通知设置
            GroupBox {
                Layout.fillWidth: true
                title: "通知设置"
                
                background: Rectangle {
                    color: "transparent"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 4
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    
                    // 桌面通知
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: desktopNotificationsCheck
                            checked: settingsDialog.settings.desktopNotifications
                            onCheckedChanged: {
                                settingsDialog.settings.desktopNotifications = checked
                            }
                        }
                        
                        Text {
                            text: "桌面通知"
                            font.pixelSize: 14
                            color: "#212529"
                        }
                    }
                    
                    // 声音提醒
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: soundAlertsCheck
                            checked: settingsDialog.settings.soundAlerts
                            onCheckedChanged: {
                                settingsDialog.settings.soundAlerts = checked
                            }
                        }
                        
                        Text {
                            text: "声音提醒"
                            font.pixelSize: 14
                            color: "#212529"
                        }
                    }
                    
                    // 消息预览
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: messagePreviewCheck
                            checked: settingsDialog.settings.messagePreview
                            onCheckedChanged: {
                                settingsDialog.settings.messagePreview = checked
                            }
                        }
                        
                        Text {
                            text: "消息预览"
                            font.pixelSize: 14
                            color: "#212529"
                        }
                    }
                }
            }
            
            // 聊天设置
            GroupBox {
                Layout.fillWidth: true
                title: "聊天设置"
                
                background: Rectangle {
                    color: "transparent"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 4
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    
                    // 最后在线时间
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: lastSeenCheck
                            checked: settingsDialog.settings.showLastSeen
                            onCheckedChanged: {
                                settingsDialog.settings.showLastSeen = checked
                            }
                        }
                        
                        Text {
                            text: "最后在线时间"
                            font.pixelSize: 14
                            color: "#212529"
                        }
                    }
                    
                    // 正在输入状态
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: typingStatusCheck
                            checked: settingsDialog.settings.showTypingStatus
                            onCheckedChanged: {
                                settingsDialog.settings.showTypingStatus = checked
                            }
                        }
                        
                        Text {
                            text: "正在输入状态"
                            font.pixelSize: 14
                            color: "#212529"
                        }
                    }
                }
            }
        }
    }
    
    footer: DialogButtonBox {
        Button {
            text: "确定"
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            
            background: Rectangle {
                color: parent.pressed ? "#0056b3" : (parent.hovered ? "#0069d9" : "#007bff")
                radius: 4
            }
            
            contentItem: Text {
                text: parent.text
                color: "white"
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
    
    onAccepted: {
        console.log("设置已保存:", JSON.stringify(settings))
        // 这里可以保存设置到本地存储
    }
}
