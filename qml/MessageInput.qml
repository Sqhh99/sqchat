import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: messageInput
    color: "#ffffff"
    
    signal messageSent(string text)
    signal typingChanged(bool typing)
      property alias text: textInput.text
    property bool isSending: false
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // 附件按钮
        Button {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            
            background: Rectangle {
                color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "transparent")
                radius: 18
                border.color: "#e9ecef"
                border.width: 1
            }
            
            contentItem: Text {
                text: "📎"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: console.log("选择附件")
        }
        
        // 输入框区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "#f8f9fa"
            border.color: textInput.activeFocus ? "#007bff" : "#e9ecef"
            border.width: 2
            radius: 24
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 12
                
                TextInput {
                    id: textInput
                    width: parent.width
                    font.pixelSize: 14
                    color: "#212529"
                    selectByMouse: true
                    wrapMode: TextInput.Wrap
                    
                    Keys.onReturnPressed: function(event) {
                        if (event.modifiers & Qt.ShiftModifier) {
                            // Shift+Enter 换行
                            text += "\n"
                        } else {
                            // Enter 发送消息
                            event.accepted = true
                            if (textInput.text.trim() !== "") {
                                messageInput.messageSent(textInput.text)
                                textInput.text = ""
                                textInput.isTyping = false
                                messageInput.typingChanged(false)
                            }
                        }
                    }
                    
                    onTextChanged: {
                        // 触发输入状态
                        typingTimer.restart()
                        if (!isTyping) {
                            isTyping = true
                            messageInput.typingChanged(true)
                        }
                    }
                    
                    property bool isTyping: false
                    
                    Timer {
                        id: typingTimer
                        interval: 2000
                        onTriggered: {
                            textInput.isTyping = false
                            messageInput.typingChanged(false)
                        }
                    }
                }
                
                // 占位符文本
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "输入消息..."
                    color: "#adb5bd"
                    font.pixelSize: 14
                    visible: textInput.text === ""
                }
            }
        }
        
        // 表情按钮
        Button {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            
            background: Rectangle {
                color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "transparent")
                radius: 18
                border.color: "#e9ecef"
                border.width: 1
            }
            
            contentItem: Text {
                text: "😊"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: console.log("选择表情")
        }
        
        // 发送按钮
        Button {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            enabled: textInput.text.trim() !== ""
            
            background: Rectangle {
                color: {
                    if (!parent.enabled) return "#e9ecef"
                    if (parent.pressed) return "#0056b3"
                    if (parent.hovered) return "#0069d9"
                    return "#007bff"
                }
                radius: 18
            }
            
            contentItem: Text {
                text: "➤"
                font.pixelSize: 16
                color: parent.enabled ? "white" : "#6c757d"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: sendMessage()
        }
    }    function sendMessage() {
        console.log("MessageInput.sendMessage called")
        
        // 防抖机制，避免重复调用
        if (isSending) {
            console.log("Already sending, ignoring")
            return
        }
        
        var text = textInput.text.trim()
        console.log("Text to send:", text)
        if (text !== "") {
            isSending = true
            console.log("Emitting messageSent signal")
            messageInput.messageSent(text)
            textInput.text = ""
            textInput.isTyping = false
            messageInput.typingChanged(false)
            console.log("Text cleared, input text now:", textInput.text)
            // 延迟重置发送状态
            resetSendingTimer.start()
        } else {
            console.log("Text is empty, not sending")
        }
    }
    
    Timer {
        id: resetSendingTimer
        interval: 100
        onTriggered: {
            messageInput.isSending = false
        }
    }
}
