import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: loginWindow
    width: 420
    height: 580
    visible: true
    title: qsTr("SQChat - 登录")
    color: "#00000000" // 使用透明颜色隐藏窗口
    
    // 移除默认的标题栏和边框
    flags: Qt.Window | Qt.FramelessWindowHint
    property bool isSignUp: false
    property bool isDragging: false
    property point startPos: Qt.point(0, 0)
    
    // 定义信号
    signal registerClicked()
    signal loginClicked(string email, string password)
    
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
                        loginWindow.x += delta.x
                        loginWindow.y += delta.y
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
                        onClicked: loginWindow.showMinimized()
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
            anchors.verticalCenterOffset: -10  // 向上移动一点
            spacing: 20  // 减少间距
            width: 340

            // Logo和标题
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Rectangle {
                    width: 70
                    height: 70
                    color: "#4f46e5"
                    radius: 18
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "Chat"
                        anchors.centerIn: parent
                        font.pixelSize: 28
                        font.bold: true
                        color: "white"
                    }
                }
                
                Text {
                    text: "sqchat Login"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#1a1a1a"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Enter your details to get sign in\nto your account"
                    font.pixelSize: 14
                    color: "#666"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    lineHeight: 1.3
                }
            }

            // 登录表单
            Column {
                width: parent.width
                spacing: 18

                // email输入框
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "email*"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1a1a1a"
                    }

                    Rectangle {
                        width: parent.width
                        height: 45
                        border.color: agencyField.activeFocus ? "#4f46e5" : "#d1d5db"
                        border.width: 2
                        radius: 8
                        color: "white"

                        TextInput {
                            id: agencyField
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            font.pixelSize: 16
                            text: "sqhh99"
                            selectByMouse: true
                            color: "#1a1a1a"
                        }
                    }
                }                // password输入框
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "password*"
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
                            text: "200400"
                            selectByMouse: true
                            color: "#1a1a1a"
                            echoMode: parent.showPassword ? TextInput.Normal : TextInput.Password
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
                    text: "This information will be securely saved as per the <u>Terms of Service</u> & <u>Privacy Policy</u>"
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

                    // Login按钮
                    Rectangle {
                        width: (parent.width - 12) / 2
                        height: 45
                        color: loginBtn.pressed ? "#f59e0b" : "#fbbf24"
                        radius: 8

                        Text {
                            text: "login"
                            anchors.centerIn: parent
                            font.pixelSize: 15
                            font.bold: true
                            color: "#1a1a1a"
                        }                        MouseArea {
                            id: loginBtn
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("login clicked")
                                loginWindow.loginClicked(agencyField.text, passwordField.text)
                            }
                        }
                    }

                    // registe按钮
                    Rectangle {
                        width: (parent.width - 12) / 2
                        height: 45
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 8
                        color: registerBtn.pressed ? "#f5f5f5" : "white"

                        Text {
                            text: "register"
                            anchors.centerIn: parent
                            font.pixelSize: 15
                            font.bold: true
                            color: "#1a1a1a"
                        }                        MouseArea {
                            id: registerBtn
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("register clicked")
                                loginWindow.registerClicked()
                            }
                        }
                    }


                }
            }

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
            }            // 连接状态指示器
            Rectangle {
                width: parent.width
                height: 25  // 减少高度
                color: "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 6  // 减少间距
                    
                    Rectangle {
                        width: 6  // 稍微小一点
                        height: 6
                        radius: 3
                        color: globalAuthController.isConnected ? "#22c55e" : "#ef4444"
                        
                        SequentialAnimation on opacity {
                            running: !globalAuthController.isConnected
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.3; duration: 800 }
                            NumberAnimation { to: 1.0; duration: 800 }
                        }
                    }
                    
                    Text {
                        text: globalAuthController.isConnected ? "已连接" : "连接中..."  // 缩短文字
                        font.pixelSize: 11  // 稍微小一点
                        color: globalAuthController.isConnected ? "#22c55e" : "#ef4444"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
