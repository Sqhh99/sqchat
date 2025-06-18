import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: registerWindow
    width: 420
    height: 580
    visible: true
    title: qsTr("SQChat - 注册")
    color: "#00000000" // 使用透明颜色隐藏窗口
    
    // 移除默认的标题栏和边框
    flags: Qt.Window | Qt.FramelessWindowHint
    property bool isDragging: false
    property point startPos: Qt.point(0, 0)
    
    // 定义信号
    signal backToLoginClicked()
    signal registerClicked(string username, string email, string verifyCode, string password)
    signal sendVerifyCodeClicked(string email)
    
    // 添加消息显示功能
    function showError(message) {
        messageDisplay.showMessage(message, true)
    }
    
    function showSuccess(message) {
        messageDisplay.showMessage(message, false)
    }

    Rectangle {
        anchors.fill: parent
        color: "#f8f9fa"
        radius: 10
        border.color: "#e0e0e0"
        border.width: 1

        // 自定义标题栏
        Rectangle {
            id: titleBar
            width: parent.width
            height: 50
            color: "transparent"
            z: 100

            // 拖拽区域
            MouseArea {
                anchors.fill: parent
                anchors.rightMargin: 80 // 为按钮留出空间
                acceptedButtons: Qt.LeftButton
                property point clickPos

                onPressed: function(mouse) {
                    clickPos = Qt.point(mouse.x, mouse.y)
                    isDragging = true
                }

                onPositionChanged: function(mouse) {
                    if (isDragging) {
                        var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                        registerWindow.x += delta.x
                        registerWindow.y += delta.y
                    }
                }

                onReleased: {
                    isDragging = false
                }
            }

            // 窗口控制按钮
            Row {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 15
                anchors.topMargin: 15
                spacing: 8

                // 最小化按钮
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: minimizeBtn.containsMouse ? "#e0e0e0" : "transparent"
                    border.color: "#ddd"
                    border.width: 1

                    Text {
                        text: "−"
                        anchors.centerIn: parent
                        font.pixelSize: 12
                        font.bold: true
                        color: "#666"
                    }

                    MouseArea {
                        id: minimizeBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: registerWindow.showMinimized()
                    }
                }

                // 关闭按钮
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: closeBtn.containsMouse ? "#ff5252" : "transparent"
                    border.color: closeBtn.containsMouse ? "#ff5252" : "#ddd"
                    border.width: 1

                    Text {
                        text: "×"
                        anchors.centerIn: parent
                        font.pixelSize: 14
                        font.bold: true
                        color: closeBtn.containsMouse ? "white" : "#666"
                    }

                    MouseArea {
                        id: closeBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.quit()
                    }
                }
            }
        }        // 主内容区域
        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -20
            spacing: 20
            width: 340

            // 消息显示组件
            Rectangle {
                id: messageDisplay
                width: parent.width
                height: messageText.height + 20
                color: isError ? "#fee2e2" : "#d1fae5"
                border.color: isError ? "#f87171" : "#34d399"
                border.width: 1
                radius: 8
                visible: false
                
                property bool isError: false
                property alias text: messageText.text
                
                function showMessage(message, error) {
                    messageText.text = message
                    isError = error
                    visible = true
                    hideTimer.restart()
                }
                
                Text {
                    id: messageText
                    anchors.centerIn: parent
                    font.pixelSize: 14
                    color: messageDisplay.isError ? "#dc2626" : "#059669"
                    wrapMode: Text.WordWrap
                    width: parent.width - 20
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Timer {
                    id: hideTimer
                    interval: 5000 // 5秒后自动隐藏
                    onTriggered: messageDisplay.visible = false
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: messageDisplay.visible = false
                }
            }

            // 连接状态指示器
            Rectangle {
                width: parent.width
                height: 30
                color: "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: globalAuthController.isConnected ? "#22c55e" : "#ef4444"
                        
                        SequentialAnimation on opacity {
                            running: !globalAuthController.isConnected
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.3; duration: 800 }
                            NumberAnimation { to: 1.0; duration: 800 }
                        }
                    }
                    
                    Text {
                        text: globalAuthController.isConnected ? "服务器已连接" : "正在连接服务器..."
                        font.pixelSize: 12
                        color: globalAuthController.isConnected ? "#22c55e" : "#ef4444"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // 注册表单
            Column {
                width: parent.width
                spacing: 16

                // 用户名输入框
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "用户名*"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1a1a1a"
                    }

                    Rectangle {
                        width: parent.width
                        height: 45
                        border.color: usernameField.activeFocus ? "#4f46e5" : "#d1d5db"
                        border.width: 2
                        radius: 8
                        color: "white"
                        TextInput {
                            id: usernameField
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            font.pixelSize: 16
                            selectByMouse: true
                            color: "#1a1a1a"
                        }
                        
                        Text {
                            text: "请输入用户名"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 16
                            font.pixelSize: 16
                            color: "#999"
                            visible: usernameField.text.length === 0 && !usernameField.activeFocus
                        }
                    }
                }

                // 邮箱输入框
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "邮箱*"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1a1a1a"
                    }

                    Rectangle {
                        width: parent.width
                        height: 45
                        border.color: emailField.activeFocus ? "#4f46e5" : "#d1d5db"
                        border.width: 2
                        radius: 8
                        color: "white"
                        TextInput {
                            id: emailField
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            font.pixelSize: 16
                            selectByMouse: true
                            color: "#1a1a1a"
                        }
                        
                        Text {
                            text: "请输入邮箱地址"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 16
                            font.pixelSize: 16
                            color: "#999"
                            visible: emailField.text.length === 0 && !emailField.activeFocus
                        }
                    }
                }

                // 邮箱验证码输入框
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "邮箱验证码*"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1a1a1a"
                    }

                    Row {
                        width: parent.width
                        spacing: 12

                        Rectangle {
                            width: parent.width - 120
                            height: 45
                            border.color: verifyCodeField.activeFocus ? "#4f46e5" : "#d1d5db"
                            border.width: 2
                            radius: 8
                            color: "white"
                            TextInput {
                                id: verifyCodeField
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                font.pixelSize: 16
                                selectByMouse: true
                                color: "#1a1a1a"
                            }
                            
                            Text {
                                text: "请输入验证码"
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 16
                                font.pixelSize: 16
                                color: "#999"
                                visible: verifyCodeField.text.length === 0 && !verifyCodeField.activeFocus
                            }
                        }

                        // 发送验证码按钮
                        Rectangle {
                            width: 108
                            height: 45
                            color: sendCodeBtn.pressed ? "#3730a3" : "#4f46e5"
                            radius: 8

                            Text {
                                text: "发送验证码"
                                anchors.centerIn: parent
                                font.pixelSize: 12
                                font.bold: true
                                color: "white"
                            }                            MouseArea {
                                id: sendCodeBtn
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("发送验证码 clicked")
                                    registerWindow.sendVerifyCodeClicked(emailField.text)
                                }
                            }
                        }
                    }
                }                // 密码输入框
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "密码*"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1a1a1a"
                    }

                    Rectangle {
                        width: parent.width
                        height: 45
                        border.color: passwordField.activeFocus ? "#4f46e5" : "#d1d5db"
                        border.width: 2
                        radius: 8
                        color: "white"

                        property bool showPassword: false

                        TextInput {
                            id: passwordField
                            anchors.left: parent.left
                            anchors.right: showPasswordBtn.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 16
                            anchors.rightMargin: 8
                            font.pixelSize: 16
                            selectByMouse: true
                            color: "#1a1a1a"
                            echoMode: parent.showPassword ? TextInput.Normal : TextInput.Password
                        }
                        
                        Text {
                            text: "请输入密码"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 16
                            font.pixelSize: 16
                            color: "#999"
                            visible: passwordField.text.length === 0 && !passwordField.activeFocus
                        }

                        // 显示/隐藏密码按钮
                        Rectangle {
                            id: showPasswordBtn
                            width: 32
                            height: 32
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 8
                            radius: 4
                            color: showPasswordMA.containsMouse ? "#f0f0f0" : "transparent"

                            Text {
                                text: parent.parent.showPassword ? "🙈" : "👁"
                                anchors.centerIn: parent
                                font.pixelSize: 16
                                color: "#666"
                            }

                            MouseArea {
                                id: showPasswordMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    parent.parent.showPassword = !parent.parent.showPassword
                                }
                            }
                        }
                    }
                }

                // 条款和隐私政策
                Text {
                    text: "点击注册即表示您同意我们的 <u>用户协议</u> 和 <u>隐私政策</u>"
                    font.pixelSize: 12
                    color: "#666"
                    wrapMode: Text.WordWrap
                    width: parent.width
                    textFormat: Text.RichText
                }

                // 按钮行
                Row {
                    width: parent.width
                    spacing: 12

                    // 注册按钮
                    Rectangle {
                        width: (parent.width - 12) / 2
                        height: 45
                        color: registerBtn.pressed ? "#f59e0b" : "#fbbf24"
                        radius: 8

                        Text {
                            text: "注册"
                            anchors.centerIn: parent
                            font.pixelSize: 15
                            font.bold: true
                            color: "#1a1a1a"
                        }                        MouseArea {
                            id: registerBtn
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("注册 clicked")
                                registerWindow.registerClicked(
                                    usernameField.text,
                                    emailField.text,
                                    verifyCodeField.text,
                                    passwordField.text
                                )
                            }
                        }
                    }

                    // 返回登录按钮
                    Rectangle {
                        width: (parent.width - 12) / 2
                        height: 45
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 8
                        color: backToLoginBtn.pressed ? "#f5f5f5" : "white"

                        Text {
                            text: "返回登录"
                            anchors.centerIn: parent
                            font.pixelSize: 15
                            font.bold: true
                            color: "#1a1a1a"
                        }                        MouseArea {
                            id: backToLoginBtn
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("返回登录 clicked")
                                registerWindow.backToLoginClicked()
                            }
                        }
                    }
                }
            }
        }
    }
}
