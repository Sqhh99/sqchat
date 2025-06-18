import QtQuick
import QtQuick.Controls
import SQChat 1.0

Item {
    id: app
    
    property var loginWindow: null
    property var registerWindow: null
    property var chatWindow: null
    
    property var pendingLoginRequest: null
    property var pendingRegisterRequest: null
    property var pendingVerifyCodeRequest: null
      // 使用全局的AuthController
    property var authController: globalAuthController
    
    Component.onCompleted: {
        // 连接AuthController信号
        authController.loginSuccess.connect(function(userId, username) {
            console.log("登录成功! 用户ID:", userId, "用户名:", username)
            showChatWindow()
        })
        
        authController.loginFailed.connect(function(error) {
            console.log("登录失败:", error)
            if (loginWindow) {
                loginWindow.showError("登录失败: " + error)
            }
        })
        
        authController.registerSuccess.connect(function(userId) {
            console.log("注册成功! 用户ID:", userId)
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
        authController.connected.connect(function() {
            console.log("连接建立成功")
            
            // 处理待处理的请求
            if (pendingLoginRequest) {
                console.log("执行待处理的登录请求...")
                authController.login(pendingLoginRequest.email, pendingLoginRequest.password)
                pendingLoginRequest = null
            }
            if (pendingRegisterRequest) {
                console.log("执行待处理的注册请求...")
                authController.registerUser(
                    pendingRegisterRequest.username,
                    pendingRegisterRequest.email, 
                    pendingRegisterRequest.password,
                    pendingRegisterRequest.verifyCode
                )
                pendingRegisterRequest = null
            }
            if (pendingVerifyCodeRequest) {
                console.log("执行待处理的验证码请求...")
                authController.sendVerifyCode(pendingVerifyCodeRequest.email)
                pendingVerifyCodeRequest = null
            }
        })
        
        authController.disconnected.connect(function() {
            console.log("服务器连接断开")
            if (loginWindow) {
                loginWindow.showError("服务器连接断开")
            }
            if (registerWindow) {
                registerWindow.showError("服务器连接断开")
            }
        })
        
        authController.connectionError.connect(function(error) {
            console.log("连接错误:", error)
            if (loginWindow) {
                loginWindow.showError("连接错误: " + error)
            }
            if (registerWindow) {
                registerWindow.showError("连接错误: " + error)
            }
        })
          // 应用启动时显示登录窗口
        showLoginWindow()
        
        // 立即开始连接服务器，不延迟
        console.log("开始连接服务器...")
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
    
    // 显示聊天窗口
    function showChatWindow() {
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
    }    // 处理登录
    function handleLogin(email, password) {
        console.log("处理登录:", email, password)
        
        if (!email || !password) {
            console.log("请填写完整的登录信息")
            if (loginWindow) {
                loginWindow.showError("请填写完整的登录信息")
            }
            return
        }
        
        if (!authController.isConnected) {
            console.log("保存登录请求，等待连接建立...")
            pendingLoginRequest = { email: email, password: password }
            
            if (loginWindow) {
                loginWindow.showError("正在连接服务器，请稍候...")
            }
            
            // 尝试连接服务器（如果还没有连接的话）
            authController.connectToServer()
            return
        }
        
        // 清除任何待处理的请求
        pendingLoginRequest = null
        authController.login(email, password)
    }    // 处理注册
    function handleRegister(username, email, verifyCode, password) {
        console.log("处理注册:", username, email, verifyCode, password)
        
        if (!username || !email || !verifyCode || !password) {
            console.log("请填写完整的注册信息")
            if (registerWindow) {
                registerWindow.showError("请填写完整的注册信息")
            }
            return
        }
        
        if (!authController.isConnected) {
            console.log("保存注册请求，等待连接建立...")
            pendingRegisterRequest = { 
                username: username, 
                email: email, 
                verifyCode: verifyCode, 
                password: password 
            }
            
            if (registerWindow) {
                registerWindow.showError("正在连接服务器，请稍候...")
            }
            authController.connectToServer()
            return
        }
        
        pendingRegisterRequest = null
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
        
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        if (!emailRegex.test(email)) {
            console.log("邮箱格式不正确")
            if (registerWindow) {
                registerWindow.showError("邮箱格式不正确")
            }
            return
        }
        
        if (!authController.isConnected) {
            console.log("保存验证码请求，等待连接建立...")
            pendingVerifyCodeRequest = { email: email }
            
            if (registerWindow) {
                registerWindow.showError("正在连接服务器，请稍候...")
            }
            authController.connectToServer()
            return
        }
        
        pendingVerifyCodeRequest = null
        authController.sendVerifyCode(email)
    }
}
