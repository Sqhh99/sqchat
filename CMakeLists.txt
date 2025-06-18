cmake_minimum_required(VERSION 3.16)

project(sqchat VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_PREFIX_PATH "D:/Qt/6.9.1/msvc2022_64")

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 QuickEffects Network)

qt_standard_project_setup(REQUIRES 6.8)

# 确保 MOC 处理
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

qt_add_executable(appsqchat
    main.cpp
    src/NetworkManager.cpp
    src/AuthController.cpp
    src/Message.cpp
    src/ChatController.cpp
    src/ChatHistoryManager.cpp
    include/NetworkManager.h
    include/AuthController.h
    include/Message.h
    include/MessageType.h
    include/ChatController.h
    include/ChatHistoryManager.h
)

# 设置包含目录
target_include_directories(appsqchat PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

qt_add_qml_module(appsqchat
    URI sqchat
    VERSION 1.0
    NO_GENERATE_QMLTYPES
    QML_FILES
        Main.qml
        LoginWindow.qml
        RegisterWindow.qml
        ChatWindow.qml
        ContactSidebar.qml
        ContactItem.qml
        ChatArea.qml
        ChatHeader.qml
        MessageBubble.qml
        MessageInput.qml
        SettingsDialog.qml
        NotificationManager.qml
        NotificationPopup.qml
        AddFriendDialog.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appsqchat PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appsqchat
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appsqchat
    PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::QuickEffects Qt6::Network
)

include(GNUInstallDirs)
install(TARGETS appsqchat
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
