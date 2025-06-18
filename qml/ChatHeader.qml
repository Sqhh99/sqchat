import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: chatHeader
    color: "#ffffff"
    
    property string chatName: ""
    property bool isTyping: false
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // 头像
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: "#e9ecef"
            border.color: "#22c55e"
            border.width: 2
            
            Text {
                anchors.centerIn: parent
                text: "👤"
                font.pixelSize: 18
            }
        }
        
        // 联系人信息
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
                text: chatHeader.chatName
                font.pixelSize: 18
                font.weight: Font.DemiBold
                color: "#212529"
            }
            
            Text {
                text: chatHeader.isTyping ? "正在输入..." : "在线"
                font.pixelSize: 12
                color: chatHeader.isTyping ? "#007bff" : "#22c55e"
                
                SequentialAnimation on opacity {
                    running: chatHeader.isTyping
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 800 }
                    NumberAnimation { to: 1.0; duration: 800 }
                }
            }
        }
        
        // 操作按钮
        RowLayout {
            spacing: 8
            
            Button {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                
                background: Rectangle {
                    color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "transparent")
                    radius: 18
                }
                
                contentItem: Text {
                    text: "📞"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: console.log("语音通话")
            }
            
            Button {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                
                background: Rectangle {
                    color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "transparent")
                    radius: 18
                }
                
                contentItem: Text {
                    text: "📹"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: console.log("视频通话")
            }
            
            Button {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                
                background: Rectangle {
                    color: parent.pressed ? "#e9ecef" : (parent.hovered ? "#f8f9fa" : "transparent")
                    radius: 18
                }
                
                contentItem: Text {
                    text: "⋮"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: console.log("更多选项")
            }
        }
    }
}
