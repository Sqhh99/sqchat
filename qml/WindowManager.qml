import QtQuick
import QtQuick.Controls
import SQChat 1.0

QtObject {
    id: windowManager
    
    property var loginWindow: null
    property var registerWindow: null
    property var chatWindow: null
    
    // 使用全局的AuthController
    property AuthController authController: globalAuthController
    
    Component.onCompleted: {
        // 连接AuthController信号
        authController.loginSuccess.connect(function(userId, username) {
            console.log("登录成功! 用户ID:", userId, "用户名:", username)
            showChatWindow()
        })
        
        authController.loginFailed.connect(function(error) {
            console.log("登录失败:", error)
            // 这里可以显示错误消息，比如通过信号通知登录窗口
            if (loginWindow) {
                loginWindow.showError("登录失败: " + error)
            }
        })
        
        authController.registerSuccess.connect(function(userId) {
            console.log("注册成功! 用户ID:", userId)
            // 注册成功后回到登录界面
            showLoginWindow()
            if (loginWindow) {
                loginWindow.showSuccess("注册成功！请使用新账户登录")
            }
        })
        
        authController.registerFailed.connect(function(error) {
            console.log("注册失败:", error)
            if (registerWindow) {
                registerWindow.showError("注册失败: " + error)
            }
        })
        
        authController.verifyCodeSent.connect(function() {
            console.log("验证码发送成功")
            if (registerWindow) {
                registerWindow.showSuccess("验证码已发送到邮箱，请查收")
            }
        })
        
        authController.verifyCodeFailed.connect(function(error) {
            console.log("验证码发送失败:", error)
            if (registerWindow) {
                registerWindow.showError("验证码发送失败: " + error)
            }
        })
        
        authController.connectionError.connect(function(error) {
            console.log("连接错误:", error)
        })
        
        // 自动连接到服务器
        authController.connectToServer()
    }
    
    // 显示登录窗口
    function showLoginWindow() {
        if (registerWindow) {
            registerWindow.close()
            registerWindow.destroy()
            registerWindow = null
        }
        
        if (!loginWindow) {
            var component = Qt.createComponent("LoginWindow.qml")
            if (component.status === Component.Ready) {
                loginWindow = component.createObject(null)
                // 连接信号
                loginWindow.registerClicked.connect(showRegisterWindow)
                loginWindow.loginClicked.connect(handleLogin)
                loginWindow.show()
            } else {
                console.error("Error loading LoginWindow:", component.errorString())
            }
        } else {
            loginWindow.show()
            loginWindow.raise()
        }
    }
    
    // 显示注册窗口
    function showRegisterWindow() {
        if (loginWindow) {
            loginWindow.close()
            loginWindow.destroy()
            loginWindow = null
        }
        
        if (!registerWindow) {
            var component = Qt.createComponent("RegisterWindow.qml")
            if (component.status === Component.Ready) {
                registerWindow = component.createObject(null)
                // 连接信号
                registerWindow.backToLoginClicked.connect(showLoginWindow)
                registerWindow.registerClicked.connect(handleRegister)
                registerWindow.sendVerifyCodeClicked.connect(handleSendVerifyCode)
                registerWindow.show()
            } else {
                console.error("Error loading RegisterWindow:", component.errorString())
            }
        } else {
            registerWindow.show()
            registerWindow.raise()
        }
    }
    
    // 处理登录
    function handleLogin(email, password) {
        console.log("处理登录:", email, password)
        
        if (!email || !password) {
            console.log("请填写完整的登录信息")
            if (loginWindow) {
                loginWindow.showError("请填写完整的登录信息")
            }
            return
        }
        
        // 检查连接状态
        if (!authController.isConnected) {
            console.log("未连接到服务器，尝试重新连接...")
            if (loginWindow) {
                loginWindow.showError("未连接到服务器，请稍后重试")
            }
            authController.connectToServer()
            return
        }
        
        // 发送登录请求
        authController.login(email, password)
    }
    
    // 显示聊天窗口
    function showChatWindow() {
        // 关闭登录和注册窗口
        if (loginWindow) {
            loginWindow.close()
            loginWindow.destroy()
            loginWindow = null
        }
        
        if (registerWindow) {
            registerWindow.close()
            registerWindow.destroy()
            registerWindow = null
        }
        
        if (!chatWindow) {
            var component = Qt.createComponent("ChatWindow.qml")
            if (component.status === Component.Ready) {
                chatWindow = component.createObject(null)
                chatWindow.show()
            } else {
                console.error("Error loading ChatWindow:", component.errorString())
            }
        } else {
            chatWindow.show()
            chatWindow.raise()
        }
    }
    
    // 处理注册
    function handleRegister(username, email, verifyCode, password) {
        console.log("处理注册:", username, email, verifyCode, password)
        
        if (!username || !email || !verifyCode || !password) {
            console.log("请填写完整的注册信息")
            if (registerWindow) {
                registerWindow.showError("请填写完整的注册信息")
            }
            return
        }
        
        // 检查连接状态
        if (!authController.isConnected) {
            console.log("未连接到服务器，尝试重新连接...")
            if (registerWindow) {
                registerWindow.showError("未连接到服务器，请稍后重试")
            }
            authController.connectToServer()
            return
        }
        
        // 发送注册请求
        authController.registerUser(username, email, password, verifyCode)
    }
    
    // 处理发送验证码
    function handleSendVerifyCode(email) {
        console.log("发送验证码到邮箱:", email)
        
        if (!email) {
            console.log("请先填写邮箱地址")
            if (registerWindow) {
                registerWindow.showError("请先填写邮箱地址")
            }
            return
        }
        
        // 简单的邮箱格式验证
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        if (!emailRegex.test(email)) {
            console.log("邮箱格式不正确")
            if (registerWindow) {
                registerWindow.showError("邮箱格式不正确")
            }
            return
        }
        
        // 检查连接状态
        if (!authController.isConnected) {
            console.log("未连接到服务器，尝试重新连接...")
            if (registerWindow) {
                registerWindow.showError("未连接到服务器，请稍后重试")
            }
            authController.connectToServer()
            return
        }
        
        // 发送验证码请求
        authController.sendVerifyCode(email)
    }
    
    // 关闭所有窗口
    function closeAll() {
        if (loginWindow) {
            loginWindow.close()
            loginWindow.destroy()
        }
        if (registerWindow) {
            registerWindow.close()
            registerWindow.destroy()
        }
        if (chatWindow) {
            chatWindow.close()
            chatWindow.destroy()
        }
        
        // 登出并断开连接
        if (authController.isLoggedIn) {
            authController.logout()
        }
        authController.disconnectFromServer()
        
        Qt.quit()
    }
}
