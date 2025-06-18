# SQChat - 基于Qt的跨平台聊天应用

一个使用Qt 6.9.1 + QML开发的现代化聊天应用，支持实时私聊、群聊和好友管理功能。

## 🌟 功能特性

- 🔐 **用户认证系统** - 安全的登录注册机制
- 💬 **实时通信** - 支持私聊和群聊功能
- 👥 **好友管理** - 添加好友、好友列表、在线状态
- 📝 **聊天历史** - 消息持久化和历史记录查询
- 🎨 **现代化UI** - Material Design风格的QML界面
- 🌐 **跨平台支持** - Windows、Linux等平台兼容
- ⚡ **高性能** - TCP Socket长连接，心跳机制保持稳定

## 🛠️ 技术栈

| 技术 | 版本/描述 |
|------|-----------|
| Qt | 6.9.1 |
| QML | 声明式UI框架 |
| C++ | 17标准 |
| CMake | 构建系统 |
| TCP Socket | 网络通信 |
| JSON | 数据交换格式 |

## 📁 项目结构

```
sqchat/
├── src/                     # C++源文件
│   ├── AuthController.cpp   # 认证控制器
│   ├── ChatController.cpp   # 聊天控制器
│   ├── NetworkManager.cpp   # 网络管理器
│   └── Message.cpp          # 消息类
├── include/                 # 头文件目录
│   ├── AuthController.h
│   ├── ChatController.h
│   ├── NetworkManager.h
│   ├── Message.h
│   └── MessageType.h        # 消息类型定义
├── *.qml                    # QML界面文件
│   ├── Main.qml            # 主窗口
│   ├── LoginWindow.qml     # 登录界面
│   ├── ChatWindow.qml      # 聊天主界面
│   ├── ContactSidebar.qml  # 联系人侧边栏
│   ├── ChatArea.qml        # 聊天区域
│   └── MessageInput.qml    # 消息输入框
├── main.cpp                 # 应用程序入口
├── CMakeLists.txt          # CMake构建配置
└── README.md               # 项目说明
```

## 🚀 快速开始

### 环境要求

- Qt 6.9.1 或更高版本
- CMake 3.16+
- 支持C++17的编译器 (GCC 7+, Clang 6+, MSVC 2019+)

### 编译步骤

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/sqchat.git
cd sqchat

# 创建构建目录
mkdir build
cd build

# 配置项目
cmake .. -DCMAKE_BUILD_TYPE=Debug

# 编译
cmake --build . --config Debug

# 运行
./appsqchat  # Linux
# 或 appsqchat.exe  # Windows
```

### IDE配置

**Qt Creator:**
1. 打开 `CMakeLists.txt`
2. 配置构建套件
3. 构建并运行

**Visual Studio Code:**
1. 安装Qt扩展
2. 打开项目文件夹
3. 使用CMake插件构建

## 📱 使用说明

1. **启动应用** - 运行编译后的可执行文件
2. **登录系统** - 使用测试账户或注册新账户
   - 测试账户：用户名 `sqhh99`，密码 `200400`
3. **添加好友** - 点击右上角"+"按钮搜索并添加好友
4. **开始聊天** - 选择好友开始私聊对话

## 🏗️ 架构设计

### 核心组件

- **NetworkManager** - 网络通信管理，TCP连接和消息收发
- **AuthController** - 用户认证逻辑，登录注册处理
- **ChatController** - 聊天功能控制，消息管理和好友操作
- **Message & MessageType** - 消息模型和类型定义

### 设计模式

- **MVC模式** - 清晰的模型-视图-控制器分离
- **观察者模式** - Qt信号槽机制实现组件通信
- **组件化设计** - QML组件可复用，易维护

## 🔧 技术亮点

1. **自定义网络协议** - 基于TCP的高效消息传输协议
2. **响应式UI** - QML声明式界面，流畅的用户体验
3. **内存管理** - 智能指针和RAII确保内存安全
4. **错误处理** - 完善的异常处理和用户提示
5. **代码质量** - 现代C++特性，清晰的代码结构

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📧 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue
- 发送邮件至项目维护者

---

⭐ 如果这个项目对您有帮助，请给它一个star！
